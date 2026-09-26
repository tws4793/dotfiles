-- Look & feel: theme, status bar, explorer sidebar.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha", -- darkest; others: macchiato, frappe (latte is light)
      styles = { comments = { "italic" }, keywords = { "italic" } },
      auto_integrations = true, -- style every installed plugin that catppuccin supports
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true, enabled = vim.g.have_nerd_font },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin-nvim", -- follows the active flavour
        globalstatus = true,
        icons_enabled = vim.g.have_nerd_font,
        -- The default powerline arrows are Nerd Font glyphs too.
        section_separators = vim.g.have_nerd_font and { left = "", right = "" } or "",
        component_separators = vim.g.have_nerd_font and { left = "", right = "" } or "|",
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "lsp_status", "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "neo-tree", "lazy", "mason", "trouble", "fugitive" },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    init = function()
      -- Neo-tree is lazy-loaded, so load it early when started as `nvim <dir>`.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("user_neotree_start_dir", { clear = true }),
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then return end
          local stat = vim.uv.fs_stat(vim.fn.argv(0))
          if stat and stat.type == "directory" then require("neo-tree") end
        end,
      })
    end,
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<CR>", desc = "Toggle explorer" },
      { "<C-b>", "<cmd>Neotree toggle reveal<CR>", desc = "Toggle explorer" }, -- only reaches nvim outside tmux (tmux prefix)
      { "<leader>fe", "<cmd>Neotree focus reveal<CR>", desc = "Focus explorer" },
      { "<leader>ge", "<cmd>Neotree float git_status<CR>", desc = "Git changes (explorer)" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      window = { width = 32 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default", -- `nvim .` opens the sidebar
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".git", ".DS_Store", "node_modules" },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>j", group = "java/spring" },
        { "<leader>u", group = "toggle" },
        { "<leader>x", group = "problems" },
      },
    },
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Problems (workspace)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Problems (buffer)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Outline" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
    },
  },

  -- Pickers (Ctrl+P, search), terminal, notifications, indent guides, start screen.
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = {
        enabled = true,
        sources = { files = { hidden = true }, grep = { hidden = true } },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      words = { enabled = true }, -- highlight other uses of the symbol under cursor
      terminal = { win = { position = "bottom", height = 0.3 } },
    },
    keys = {
      { "<C-p>", function() Snacks.picker.files() end, desc = "Go to file" },
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart find" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Search in files" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Search in files" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Search word", mode = { "n", "x" } },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Open buffers" },
      { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Switch buffer" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<leader>fc", function() Snacks.picker.commands() end, desc = "Command palette" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Symbols in file" },
      { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Symbols in workspace" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>f.", function() Snacks.picker.resume() end, desc = "Resume last search" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git status" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
      { "<C-\\>", function() Snacks.terminal.toggle() end, desc = "Toggle terminal", mode = { "n", "t" } },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
    },
  },
}
