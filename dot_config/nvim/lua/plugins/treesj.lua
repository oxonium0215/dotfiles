return {
  "Wansmer/treesj",
  keys = {
    { "<leader>m", "<cmd>TSJToggle<CR>", desc = "Toggle Split/Join (TreeSJ)" },
    { "<leader>j", "<cmd>TSJJoin<CR>", desc = "Join Node (TreeSJ)" },
    { "<leader>s", "<cmd>TSJSplit<CR>", desc = "Split Node (TreeSJ)" },
  },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    use_default_keymaps = false,
  },
}
