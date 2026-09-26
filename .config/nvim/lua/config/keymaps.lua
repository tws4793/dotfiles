local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- VSCode-style save / quit
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR><Esc>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>confirm qall<CR>", { desc = "Quit all" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Buffers
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>w", function() Snacks.bufdelete() end, { desc = "Close buffer" })

-- Move lines like Alt+Up/Down in VSCode (needs Option-as-Meta in the terminal)
map("n", "<A-j>", "<cmd>move .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>move .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Terminal: leave terminal mode with Esc Esc
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Ctrl+/ toggles comments like VSCode (terminals send it as <C-_>)
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })
map("x", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })

-- Personal cheat sheet: doc/mykeys.txt, opened as a normal :help page
local function open_cheatsheet()
  pcall(vim.cmd.helptags, vim.fn.fnameescape(vim.fn.stdpath("config") .. "/doc"))
  vim.cmd.help("mykeys.txt")
end
vim.api.nvim_create_user_command("Keys", open_cheatsheet, { desc = "Open my keybinding cheat sheet" })
map("n", "<leader>?", open_cheatsheet, { desc = "Keybinding cheat sheet" })
