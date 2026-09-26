-- Git: gutter signs + inline blame, plus fugitive/gv.vim from the .vimrc.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame_opts = { delay = 300 },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "Next change")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous change")
        map("n", "<leader>gp", gs.preview_hunk, "Preview change")
        map("n", "<leader>gr", gs.reset_hunk, "Revert change")
        map("n", "<leader>gS", gs.stage_hunk, "Stage change")
        map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle inline blame")
        map("n", "<leader>gd", gs.diffthis, "Diff file")
      end,
    },
  },
  { "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "GBrowse" } },
  { "junegunn/gv.vim", cmd = "GV", dependencies = { "tpope/vim-fugitive" } },
}
