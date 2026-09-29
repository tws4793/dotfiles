local opt = vim.opt

-- Carried over from .vimrc
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.cursorline = true
opt.backup = false
opt.writebackup = false
opt.hlsearch = true
opt.cmdheight = 1
opt.ruler = true
opt.updatetime = 250
opt.shortmess:append("c")
opt.showmode = false -- lualine shows the mode

-- VSCode-ish editor feel
opt.termguicolors = true
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes" -- stop text shifting when diagnostics/git signs appear
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- share the macOS clipboard
opt.undofile = true -- persistent undo instead of backup files
opt.swapfile = false
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.inccommand = "split" -- live preview of :s substitutions
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.laststatus = 3 -- single global statusline
opt.timeoutlen = 400
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }
opt.confirm = true -- ask to save instead of failing on :q
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12
opt.smoothscroll = true
opt.winborder = "rounded" -- rounded borders on floating windows (hover, signature)
