return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy", words = { "lazy" } },
    },
  },
}
