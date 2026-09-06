return {
  "gbprod/yanky.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ring = { history_length = 100 },
    highlight = { timer = 200 },
  },
  keys = {
    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after cursor" },
    { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before cursor" },
    { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "GPut after cursor" },
    { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "GPut before cursor" },
    { "[y", "<Plug>(YankyPreviousEntry)", desc = "Cycle backward through yank history" },
    { "]y", "<Plug>(YankyNextEntry)", desc = "Cycle forward through yank history" },
    { "<leader>fy", "<cmd>Telescope yank_history<CR>", desc = "Telescope yank history" },
  },
  config = function(_, opts)
    require("yanky").setup(opts)
    pcall(function()
      require("telescope").load_extension("yank_history")
    end)
  end,
}
