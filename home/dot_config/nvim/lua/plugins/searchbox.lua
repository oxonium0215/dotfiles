local utils = require("core.utils")

return {
  "VonHeikemen/searchbox.nvim",
  keys = utils.generate_lazy_keys("searchbox"),
  cmd = { "SearchBoxIncSearch", "SearchBoxReplace" },
  dependencies = { "MunifTanjim/nui.nvim" },
}
