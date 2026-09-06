local utils = require("core.utils")

return {
  "folke/trouble.nvim",
  keys = utils.generate_lazy_keys("trouble"),
  cmd = { "Trouble" },
  opts = {
    use_diagnostic_signs = true,
  },
}
