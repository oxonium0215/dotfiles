local utils = require("core.utils")

return {
  "Mythos-404/xmake.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  enabled = function()
    return vim.fn.executable("xmake") == 1
  end,
  event = "VeryLazy",
  keys = utils.generate_lazy_keys("xmake"),
  cmd = {
    "XMakeConfig",
    "XMakeBuild",
    "XMakeRun",
    "XMakeDebug",
    "XMakeStop",
    "XMakeStatus",
    "XMakeLog",
    "XMakeClean",
    "XMakeProject",
    "XMakeMenu",
  },
  opts = {
    on_save = {
      reload_project_info = true,
      lsp_compile_commands = {
        enable = true,
        output_dir = ".",
      },
    },
    runner = {
      type = "toggleterm",
      config = {
        toggleterm = {
          direction = "float",
          close_on_success = false,
        },
      },
    },
    execute = {
      type = "toggleterm",
      config = {
        toggleterm = {
          direction = "horizontal",
          close_on_success = true,
        },
      },
    },
  },
  config = function(_, opts)
    require("xmake").setup(opts)
  end,
}
