local utils = require("core.utils")

return {
  "stevearc/overseer.nvim",
  keys = utils.generate_lazy_keys("overseer"),
  cmd = {
    "OverseerRun",
    "OverseerToggle",
    "OverseerQuickAction",
    "OverseerTaskAction",
    "OverseerBuild",
    "OverseerClearCache",
  },
  opts = {
    templates = { "builtin", "user.cpp_build", "user.script_runner" },
    strategy = { "toggleterm" },
  },
  dependencies = {
    "mfussenegger/nvim-dap",
  },
}
