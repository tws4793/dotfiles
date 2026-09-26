-- Language servers via Neovim's native LSP client (replaces coc.nvim + ALE).
-- To support another language: add its server to `servers` below
-- (names: :help lspconfig-all), or install it ad hoc with :Mason.

local servers = {
  -- Web / JS / TS (the projects/ React + TS stack)
  "vtsls", -- the same TypeScript engine VSCode uses
  "eslint",
  "html",
  "cssls",
  "emmet_language_server",
  "jsonls",
  "yamlls",
  "vue_ls", -- replaces vim-vue / coc-vetur
  "svelte",
  -- Python (replaces coc-python + ALE flake8/pydocstyle)
  "pyright", -- npm-based, so it does not depend on the local Python version
  "ruff",
  -- Everything else
  "lua_ls",
  "bashls",
  "dockerls",
  "marksman",
  "taplo",
}

-- Angular (lua/config/angular.lua) and Java/Spring Boot (lua/config/java.lua)
-- install their servers on first use instead of being listed here.

-- Formatters/linters that aren't language servers
local tools = { "prettier", "stylua", "shfmt" }

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
      "mason-org/mason-lspconfig.nvim",
      "b0o/SchemaStore.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Vue: vtsls runs the Vue TypeScript plugin so <script> blocks get full TS support.
      vim.lsp.config("vtsls", {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
        settings = {
          vtsls = {
            autoUseWorkspaceTsdk = true, -- use the project's own typescript
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server"),
                  languages = { "vue" },
                  configNamespace = "typescript",
                },
              },
            },
          },
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "literals" },
              variableTypes = { enabled = false },
              functionLikeReturnTypes = { enabled = true },
            },
            updateImportsOnFileMove = { enabled = "always" },
          },
        },
      })

      -- Angular templates are HTML too.
      vim.lsp.config("html", {
        filetypes = { "html", "htmlangular" },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = { Lua = { workspace = { checkThirdParty = false } } },
      })

      -- mason-lspconfig installs the servers and calls vim.lsp.enable() for them.
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = {
          exclude = {
            "stylua", -- conform runs stylua as a formatter
            "jdtls", -- started by nvim-jdtls (lua/config/java.lua)
          },
        },
      })

      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then pkg:install() end
        end
      end)

      vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
        float = { source = "if_many" },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
          },
        } or true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(args)
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = args.buf, desc = desc })
          end
          -- K (hover), grn (rename), gra (code action), grr (references)
          -- and <C-s> in insert (signature help) are Neovim built-ins.
          map("gd", function() Snacks.picker.lsp_definitions() end, "Go to definition")
          map("<F12>", function() Snacks.picker.lsp_definitions() end, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gI", function() Snacks.picker.lsp_implementations() end, "Go to implementation")
          map("gy", function() Snacks.picker.lsp_type_definitions() end, "Go to type definition")
          map("<S-F12>", function() Snacks.picker.lsp_references() end, "Find all references")
          map("<F2>", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
          map("<leader>uh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
          end, "Toggle inlay hints")

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "vtsls" then
            map("<leader>co", function()
              vim.lsp.buf.code_action({ apply = true, context = { only = { "source.organizeImports" }, diagnostics = {} } })
            end, "Organize imports")
          end
          -- Ruff handles lint/format; let pyright own hover.
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })
    end,
  },

  -- Neovim Lua API completion when editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } }, "snacks.nvim" } },
  },
}
