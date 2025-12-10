return {
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
}
