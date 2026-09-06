local utils = require("core.utils")

return {
  "stevearc/oil.nvim",
  keys = utils.generate_lazy_keys("oil"),
  cmd = { "Oil" },
  opts = {
    view_options = {
      show_hidden = true,
    },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
}
