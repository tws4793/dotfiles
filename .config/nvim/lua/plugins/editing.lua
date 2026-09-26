-- Editing helpers. EditorConfig and commenting (gc / gcc) are built into Neovim.
return {
  { "junegunn/vim-easy-align", keys = { { "ga", "<Plug>(EasyAlign)", mode = { "n", "x" }, desc = "Align" } }, cmd = "EasyAlign" },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = { check_ts = true } },
  { "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, opts = {} }, -- auto close/rename HTML & JSX tags
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = { { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "TODOs" } },
  },
}
