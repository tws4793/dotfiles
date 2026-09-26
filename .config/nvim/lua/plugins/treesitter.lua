-- Syntax highlighting & indentation (replaces vim-javascript, typescript-vim,
-- vim-jsx-typescript, vim-vue, vim-pug). Parsers for other languages are
-- installed automatically the first time you open such a file.
local parsers = {
  "bash", "css", "diff", "dockerfile", "git_config", "gitcommit", "gitignore",
  "html", "javascript", "jsdoc", "json", "lua", "luadoc", "markdown",
  "markdown_inline", "pug", "python", "query", "regex", "scss", "svelte",
  "toml", "tsx", "typescript", "vim", "vimdoc", "vue", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.install(parsers)

      local available = {}
      for _, lang in ipairs(ts.get_available()) do available[lang] = true end

      local function start(buf, lang)
        if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then return end
        if #vim.treesitter.query.get_files(lang, "indents") > 0 then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then return end
          if vim.treesitter.language.add(lang) then
            start(args.buf, lang)
          elseif available[lang] then
            ts.install(lang):await(vim.schedule_wrap(function() start(args.buf, lang) end))
          end
        end,
      })
    end,
  },
}
