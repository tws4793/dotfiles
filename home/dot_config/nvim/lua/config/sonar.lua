-- SonarQube for IDE (SonarLint) via sonarlint.nvim: Sonar's rules as inline
-- diagnostics, optionally connected to a SonarQube server for its quality
-- profile and known issues.
--
-- Needs JDK 17+ (the analyzer runs on Java). sonarlint-language-server is
-- installed the first time a supported file is opened on such a machine.
--
-- Connected mode is configured from the environment:
--   SONAR_HOST_URL   e.g. http://sonar-host:9000
--   SONAR_TOKEN      a SonarQube user token
-- The project key is read from the project (see project_key() below).
-- Set vim.g.sonar_enabled = false to switch the whole thing off.
local tools = require("config.tools")

local M = {}

local MIN_JDK = 17
local CONNECTION_ID = "sonarqube"
M.filetypes = {
  "java", "python",
  "javascript", "javascriptreact", "typescript", "typescriptreact",
  "html", "htmlangular", "css", "scss", "xml", "dockerfile",
}

local function read(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  return ok and table.concat(lines, "\n") or nil
end

--- SonarQube project key for a project root, first match wins:
---   .sonarlint/connectedMode.json   {"projectKey": "..."} (VS Code's shared binding file)
---   sonar-project.properties        sonar.projectKey=...
---   pom.xml                         <sonar.projectKey>...</sonar.projectKey>
---   build.gradle(.kts)              property("sonar.projectKey", "...")
function M.project_key(root)
  local function at(f) return vim.fs.joinpath(root, f) end
  local json = read(at(".sonarlint/connectedMode.json"))
  if json then
    local ok, data = pcall(vim.json.decode, json)
    if ok and type(data) == "table" and data.projectKey then return data.projectKey, ".sonarlint/connectedMode.json" end
  end
  for _, line in ipairs(vim.split(read(at("sonar-project.properties")) or "", "\n")) do
    local key = line:match("^%s*sonar%.projectKey%s*[=:]%s*(.-)%s*$")
    if key and key ~= "" then return key, "sonar-project.properties" end
  end
  local pom = read(at("pom.xml"))
  local key = pom and pom:match("<sonar%.projectKey>%s*(.-)%s*</sonar%.projectKey>")
  if key then return key, "pom.xml" end
  for _, f in ipairs({ "build.gradle", "build.gradle.kts" }) do
    local gradle = read(at(f))
    key = gradle and gradle:match([=[property%s*%(?%s*["']sonar%.projectKey["']%s*,%s*["']([^"']+)["']]=])
    if key then return key, f end
  end
end

local function root_of(buf)
  -- Same rule sonarlint.nvim uses: the git root, else the working directory.
  return vim.fs.root(buf, ".git") or vim.fn.getcwd()
end

local function server_config()
  local mason = require("mason-registry").get_package("sonarlint-language-server"):get_install_path()
  local analyzers = vim.fn.glob(vim.fs.joinpath(mason, "extension", "analyzers", "*.jar"), false, true)
  local cmd = vim.list_extend({ "sonarlint-language-server", "-stdio", "-analyzers" }, analyzers)

  local url = vim.env.SONAR_HOST_URL
  local settings = { sonarlint = {} }
  if url and url ~= "" then
    settings.sonarlint.connectedMode = {
      connections = {
        sonarqube = { { connectionId = CONNECTION_ID, serverUrl = url, disableNotifications = false } },
      },
    }
  end

  local warned = {}
  return {
    cmd = cmd,
    settings = settings,
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    get_language_id = function(_, ft)
      return ft == "htmlangular" and "html" or ft
    end,
    before_init = function(_, config)
      if not (url and url ~= "") then return end
      local root = config.root_dir or vim.fn.getcwd()
      local key = M.project_key(root)
      if key then
        config.settings.sonarlint.connectedMode.project = { connectionId = CONNECTION_ID, projectKey = key }
      elseif not warned[root] then
        warned[root] = true
        vim.notify(
          ("No SonarQube project key found for %s; using local rules only. See :SonarInfo."):format(vim.fs.basename(root)),
          vim.log.levels.WARN, { title = "sonar" })
      end
    end,
  }
end

-- sonarlint.nvim pairs its client with jdtls only when both have the *same*
-- root_dir. Its root is the git root, jdtls's is the Maven/Gradle root, so in a
-- repo with the backend in a subfolder they differ. Match by containment instead.
local function patch_jdtls_pairing()
  local utils = require("sonarlint.utils")
  local function inside(outer, inner)
    return outer and inner and (inner == outer or vim.startswith(inner, outer .. "/"))
  end
  utils.get_sonarlint_client = function(jdtls_client)
    local clients = vim.lsp.get_clients({ name = "sonarlint.nvim" })
    if not jdtls_client then return clients[1] end
    for _, c in ipairs(clients) do
      if inside(c.config.root_dir, jdtls_client.config.root_dir) then return c end
    end
  end
  utils.get_jdtls_client = function(sonarlint_client)
    for _, c in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
      if inside(sonarlint_client.config.root_dir, c.config.root_dir) then return c end
    end
  end
  -- jdtls may already be running when Sonar starts; its LspAttach hook would be missed.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user_sonar_jdtls", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not (client and client.name == "sonarlint.nvim") then return end
      for _, jdtls in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
        require("sonarlint.java").jdtls_attached_callback({ data = { client_id = jdtls.id }, buf = args.buf })
      end
    end,
  })
end

local started = false
local function start()
  if started then return end
  started = true
  require("lazy").load({ plugins = { "sonarlint.nvim" } })
  patch_jdtls_pairing()
  require("sonarlint").setup({ server = server_config(), filetypes = M.filetypes })
  -- setup() attaches on FileType; replay it for buffers opened before now.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.tbl_contains(M.filetypes, vim.bo[buf].filetype) then
      vim.api.nvim_buf_call(buf, function()
        vim.api.nvim_exec_autocmds("FileType", { pattern = vim.bo[buf].filetype, modeline = false })
      end)
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_sonar", { clear = true }),
  pattern = M.filetypes,
  callback = function()
    if started or vim.g.sonar_enabled == false then return true end
    if (tools.java_version() or 0) < MIN_JDK then return true end -- no JDK: stay off, quietly
    tools.ensure({ "sonarlint-language-server" }, start)
    return true -- one-shot: sonarlint.nvim's own autocmd takes over after start()
  end,
})

vim.api.nvim_create_user_command("SonarInfo", function()
  local root = root_of(0)
  local key, source = M.project_key(root)
  local installed = pcall(function()
    assert(require("mason-registry").get_package("sonarlint-language-server"):is_installed())
  end)
  local attached = #vim.lsp.get_clients({ bufnr = 0, name = "sonarlint.nvim" }) > 0
  local jdk = tools.java_version()
  local lines = {
    "enabled:        " .. tostring(vim.g.sonar_enabled ~= false),
    ("JDK:            %s (needs %d+)"):format(jdk or "none", MIN_JDK),
    "server package: " .. (installed and "installed" or "not installed (installs on first supported file)"),
    "this buffer:    " .. (attached and "analysed" or "not attached"),
    "SONAR_HOST_URL: " .. (vim.env.SONAR_HOST_URL or "unset → local rules only"),
    "SONAR_TOKEN:    " .. ((vim.env.SONAR_TOKEN and vim.env.SONAR_TOKEN ~= "") and "set" or "unset"),
    "project root:   " .. root,
    "project key:    " .. (key and (key .. "  (from " .. source .. ")") or "none found"),
  }
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "SonarQube" })
end, { desc = "Show SonarQube setup and connection status" })

return M
