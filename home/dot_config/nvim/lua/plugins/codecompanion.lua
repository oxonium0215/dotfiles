local utils = require("core.utils")

return {
  "olimorris/codecompanion.nvim",
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionAction" },
  keys = utils.generate_lazy_keys("codecompanion"),
  opts = {
    display = {
      chat = {
        auto_scroll = false,
        show_header_separator = true,
      },
    },
    strategies = {
      chat = {
        adapter = "copilot",
        roles = {
          llm = function(adapter)
            return "  CodeCompanion (" .. adapter.formatted_name .. ")"
          end,
          user = "  Me",
        },
      },
      inline = {
        adapter = "copilot",
      },
    },
    adapters = {
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "claude-3.7-sonnet",
            },
          },
        })
      end,
    },
  },
  config = function(_, opts)
    local ok_spinner, spinner = pcall(require, "config.codecompanion.fidget-spinner")
    if ok_spinner and spinner.init then
      spinner:init()
    end
    require("codecompanion").setup(opts)
  end,
}
