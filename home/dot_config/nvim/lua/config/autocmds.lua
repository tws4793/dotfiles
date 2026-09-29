local augroup = vim.api.nvim_create_augroup("user_config", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Flash the yanked region
autocmd("TextYankPost", {
  group = augroup,
  callback = function() vim.hl.on_yank() end,
})

-- Python: PEP 8 line length (from .vimrc)
autocmd("FileType", {
  group = augroup,
  pattern = "python",
  callback = function()
    vim.opt_local.textwidth = 79
    vim.opt_local.colorcolumn = "80"
  end,
})

-- Markdown: soft wrap, and <leader>\ aligns tables (from .vimrc)
autocmd("FileType", {
  group = augroup,
  pattern = "markdown",
  callback = function(args)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.keymap.set("x", "<leader>\\", ":EasyAlign*<Bar><CR>",
      { buffer = args.buf, desc = "Align markdown table" })
  end,
})

-- Two-space indent is the norm for web / config files.
-- .editorconfig (built into Neovim) still wins when a project has one.
autocmd("FileType", {
  group = augroup,
  pattern = {
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "vue", "svelte", "html", "css", "scss", "json", "jsonc", "yaml", "lua", "pug",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Return to the last cursor position when reopening a file
autocmd("BufReadPost", {
  group = augroup,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Reload files changed outside Neovim (e.g. by Claude Code in another tmux pane).
-- FocusGained needs `set -g focus-events on` in tmux; CursorHold covers the rest.
autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  group = augroup,
  callback = function()
    if vim.fn.getcmdwintype() == "" and vim.bo.buftype == "" then vim.cmd.checktime() end
  end,
})
