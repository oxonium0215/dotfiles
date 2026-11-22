local utils = require("core.utils")

return {
  "cordx56/rustowl",
  ft = { "rust" },
  keys = utils.generate_lazy_keys("rustowl"),
  opts = {
    auto_enable = true,
  },
}
