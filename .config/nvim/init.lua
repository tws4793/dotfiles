-- Neovim config: dark (Catppuccin Mocha), LSP-driven.
-- Layout:
--   lua/config/*   core options, keymaps, autocmds, plugin bootstrap
--   lua/plugins/*  one file per area; lazy.nvim loads them all

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true -- set false if your terminal font has no Nerd Font glyphs

-- Node is managed by fnm but not on the shell PATH; language servers need it.
local fnm_node = vim.fn.expand("~/.local/share/fnm/aliases/default/bin")
if vim.fn.executable("node") == 0 and vim.fn.isdirectory(fnm_node) == 1 then
  vim.env.PATH = fnm_node .. ":" .. vim.env.PATH
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.angular")
require("config.java")
require("config.sonar")
require("config.lazy")
