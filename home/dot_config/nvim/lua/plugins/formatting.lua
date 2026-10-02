-- Format on save (replaces vim-prettier / coc-prettier).
-- Prettier resolves from the project's node_modules first, so each project's
-- version and .prettierrc are respected; Mason's copy is the fallback.
local prettier = { "prettier" }

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, mode = { "n", "x" }, desc = "Format document" },
      {
        "<leader>uf",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
        end,
        desc = "Toggle format on save",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript = prettier,
        javascriptreact = prettier,
        typescript = prettier,
        typescriptreact = prettier,
        vue = prettier,
        html = prettier,
        htmlangular = prettier,
        css = prettier,
        scss = prettier,
        less = prettier,
        json = prettier,
        jsonc = prettier,
        yaml = prettier,
        markdown = prettier,
        graphql = prettier,
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return { timeout_ms = 1500 }
      end,
    },
  },
}
