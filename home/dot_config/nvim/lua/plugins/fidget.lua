local utils = require("core.utils")

return {
  "j-hui/fidget.nvim",
  event = "VeryLazy",
  keys = utils.generate_lazy_keys("fidget"),
  opts = {
    notification = {
      override_vim_notify = true,
    },
  },
}
