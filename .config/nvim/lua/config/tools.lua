-- On-demand tooling: install Mason packages the first time a project needs
-- them, instead of up front. Keeps machines that never open (say) a Java
-- project free of that project's toolchain.
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "tools" })
end

--- Install any missing Mason packages, then call `on_ready` once all are present.
---@param names string[]
---@param on_ready fun()
function M.ensure(names, on_ready)
  local registry = require("mason-registry")
  registry.refresh(vim.schedule_wrap(function()
    local missing = {}
    for _, name in ipairs(names) do
      local ok, pkg = pcall(registry.get_package, name)
      if not ok then
        notify("Unknown Mason package: " .. name, vim.log.levels.ERROR)
        return
      end
      if not pkg:is_installed() then table.insert(missing, pkg) end
    end
    if #missing == 0 then return on_ready() end

    local labels = vim.tbl_map(function(p) return p.name end, missing)
    notify("Installing " .. table.concat(labels, ", ") .. " (first use)…")
    for _, pkg in ipairs(missing) do
      if not pkg:is_installing() then pkg:install() end
    end

    local timer = assert(vim.uv.new_timer())
    timer:start(1000, 1000, vim.schedule_wrap(function()
      local installing, failed = false, {}
      for _, pkg in ipairs(missing) do
        if pkg:is_installing() then
          installing = true
        elseif not pkg:is_installed() then
          table.insert(failed, pkg.name)
        end
      end
      if installing then return end
      timer:stop()
      timer:close()
      if #failed > 0 then
        notify("Failed to install " .. table.concat(failed, ", ") .. " — see :Mason", vim.log.levels.ERROR)
      else
        notify("Installed " .. table.concat(labels, ", "))
        on_ready()
      end
    end))
  end))
end

local java_major -- cached: number, or false when there is no usable JDK

local function probe_java(java)
  if vim.fn.executable(java) == 0 then return nil end
  local ok, res = pcall(function()
    return vim.system({ java, "-version" }, { text = true }):wait(10000)
  end)
  if not (ok and res.code == 0) then return nil end -- e.g. the macOS /usr/bin/java stub
  local out = (res.stderr or "") .. (res.stdout or "")
  local major = tonumber(out:match('version "(%d+)'))
  if major == 1 then major = tonumber(out:match('version "1%.(%d+)')) end -- Java 8 style
  return major
end

--- Major version of the JDK on this machine, or nil. Checks $JAVA_HOME, then
--- PATH, then SDKMAN's current JDK (for when Neovim starts without the shell's
--- SDKMAN init). A JDK found that way is exported via JAVA_HOME/PATH so the
--- Java-based servers (jdtls, Spring Boot, SonarLint) use it too.
function M.java_version()
  if java_major ~= nil then return java_major or nil end
  java_major = false
  if vim.env.JAVA_HOME then
    java_major = probe_java(vim.fs.joinpath(vim.env.JAVA_HOME, "bin", "java")) or false
  end
  if not java_major then java_major = probe_java("java") or false end
  if not java_major then
    local sdkman = vim.fs.joinpath(vim.env.SDKMAN_DIR or vim.fn.expand("~/.sdkman"), "candidates", "java", "current")
    java_major = probe_java(vim.fs.joinpath(sdkman, "bin", "java")) or false
    if java_major then
      vim.env.JAVA_HOME = sdkman
      vim.env.PATH = vim.fs.joinpath(sdkman, "bin") .. ":" .. vim.env.PATH
    end
  end
  return java_major or nil
end

return M
