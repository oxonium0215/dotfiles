local M = {}

local mason_dap = require("mason-nvim-dap")
local languages = require("plugins.configs.dap.languages")

local function setup_mason_handlers(lang_modules)
  local ensure = languages.ensure_list(lang_modules)
  local handlers = languages.handlers(lang_modules)

  mason_dap.setup({
    -- ensure_installed = ensure, -- Removed for lazy loading
    handlers = vim.tbl_extend("force", {
      function(config)
        mason_dap.default_setup(config)
      end,
    }, handlers),
  })
end

local function setup_ui(dap, dapui)
  dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    controls = {
      icons = {
        pause = "󰏤",
        play = "",
        step_into = "",
        step_over = "",
        step_out = "",
        step_back = "",
        run_last = "▶▶",
        terminate = "",
        disconnect = "",
      },
    },
  })

  dap.listeners.after.event_initialized["dapui_config"] = dapui.open
  dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  dap.listeners.before.event_exited["dapui_config"] = dapui.close
end

function M.setup()
  local dap = require("dap")
  local dapui = require("dapui")
  local lang_modules = languages.load()

  setup_mason_handlers(lang_modules)

  for _, mod in ipairs(lang_modules) do
    if type(mod.setup) == "function" then
      mod.setup(dap)
    end
  end

  setup_ui(dap, dapui)

end

return M
