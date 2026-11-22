local utils = require("core.utils")

return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPost", "BufNewFile" },
  keys = utils.generate_lazy_keys("dropbar"),
}
