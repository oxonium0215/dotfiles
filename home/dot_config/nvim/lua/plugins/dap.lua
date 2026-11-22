local utils = require("core.utils")

return {
  "mfussenegger/nvim-dap",
  keys = utils.generate_lazy_keys("dap"),
  event = "VeryLazy",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
    "mason-org/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    require("config.dap").setup()
  end,
}
