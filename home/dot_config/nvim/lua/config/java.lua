-- Java / Spring Boot: jdtls (via nvim-jdtls) with Lombok, plus the Spring Boot
-- language server (application.yml/properties, beans, endpoints).
-- Nothing is installed until a Java file is opened on a machine with JDK 21+,
-- which jdtls itself needs to run (projects can still target Java 17).
local tools = require("config.tools")

local M = {}

local PACKAGES = { "jdtls", "vscode-spring-boot-tools", "lemminx" } -- lemminx: pom.xml / XML
local MIN_JDK = 21

local warned = false
local function jdk_ok()
  local v = tools.java_version()
  if v and v >= MIN_JDK then return true end
  if not warned then
    warned = true
    vim.notify(
      ("Java support is off: needs JDK %d+ (found %s). Install one and set JAVA_HOME or PATH."):format(MIN_JDK, v or "none"),
      vim.log.levels.WARN, { title = "java" })
  end
  return false
end

local spring_ready = false
local function setup_spring()
  if spring_ready then return end
  spring_ready = true
  require("spring_boot").setup({
    -- Only start the Spring language server in real Spring Boot projects.
    project_filter = function(root)
      return require("spring_boot.util").has_spring_boot_dependency(root)
    end,
  })
end

local function project_root(buf)
  return vim.fs.root(buf, {
    { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" },
    { "pom.xml", "build.gradle", "build.gradle.kts" },
    ".git",
  })
end

local function start(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local root = project_root(buf) or vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
  setup_spring()

  local jdtls_dir = require("mason-registry").get_package("jdtls"):get_install_path()
  local workspace = vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls",
    vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 8))

  require("jdtls").start_or_attach({
    name = "jdtls",
    cmd = {
      "jdtls",
      "--jvm-arg=-javaagent:" .. vim.fs.joinpath(jdtls_dir, "lombok.jar"),
      "--jvm-arg=-Xmx1g", -- cap the heap; jdtls is the heaviest server in this config
      "-data", workspace,
    },
    root_dir = root,
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    init_options = { bundles = require("spring_boot").java_extensions() },
    settings = {
      java = {
        configuration = { updateBuildConfiguration = "interactive" },
        contentProvider = { preferred = "fernflower" }, -- decompile library classes on go-to-definition
        signatureHelp = { enabled = true },
        inlayHints = { parameterNames = { enabled = "literals" } },
        saveActions = { organizeImports = false },
        completion = {
          favoriteStaticMembers = {
            "org.junit.jupiter.api.Assertions.*",
            "org.assertj.core.api.Assertions.*",
            "org.mockito.Mockito.*",
            "org.mockito.ArgumentMatchers.*",
            "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
            "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
          },
        },
        sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
      },
    },
  })
end

--- Called from ftplugin/java.lua for every Java buffer.
function M.attach(buf)
  if not jdk_ok() then return end
  tools.ensure(PACKAGES, function() start(buf) end)
end

--- Spring config files: start the Spring Boot server if the tools are already installed.
function M.attach_spring_config(buf)
  if (tools.java_version() or 0) < MIN_JDK then return end
  local ok, pkg = pcall(function() return require("mason-registry").get_package("vscode-spring-boot-tools") end)
  if not (ok and pkg:is_installed()) then return end
  require("lazy").load({ plugins = { "spring-boot.nvim" } })
  setup_spring()
  -- setup() enables the server; re-fire FileType so this already-open buffer attaches.
  vim.api.nvim_buf_call(buf, function()
    vim.api.nvim_exec_autocmds("FileType", { pattern = vim.bo[buf].filetype, modeline = false })
  end)
end

--- Build-tool command for this project: ./mvnw, ./gradlew, or system mvn/gradle.
local function build_tool(root)
  local function has(f) return vim.uv.fs_stat(vim.fs.joinpath(root, f)) ~= nil end
  if has("mvnw") then return "maven", "./mvnw" end
  if has("gradlew") then return "gradle", "./gradlew" end
  if has("pom.xml") then return "maven", "mvn" end
  return "gradle", "gradle"
end

function M.run(kind)
  local buf = vim.api.nvim_get_current_buf()
  local root = project_root(buf)
  if not root then return vim.notify("Not inside a Maven/Gradle project", vim.log.levels.WARN) end
  local tool, exe = build_tool(root)
  local class = vim.fn.expand("%:t:r")
  local cmd = ({
    maven = { test_file = exe .. " test -Dtest=" .. class, test_all = exe .. " test", run = exe .. " spring-boot:run" },
    gradle = { test_file = exe .. " test --tests '*." .. class .. "'", test_all = exe .. " test", run = exe .. " bootRun" },
  })[tool][kind]
  Snacks.terminal(cmd, { cwd = root, interactive = false, auto_close = false })
end

-- application.yml / .properties: start the Spring Boot server when tools are present.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("user_spring_config", { clear = true }),
  pattern = { "application*.yml", "application*.yaml", "application*.properties", "bootstrap*.yml" },
  callback = function(args) M.attach_spring_config(args.buf) end,
})

return M
