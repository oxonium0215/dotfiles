return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "darker",
    lualine = {},
  },
  config = function(_, opts)
    require("onedark").setup(opts)
    require("onedark").load()
  end,
}
