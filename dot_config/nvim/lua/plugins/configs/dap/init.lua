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

  local function setup_launchjs()
    local vscode = require("dap.ext.vscode")

    -- Try to load overseer (and its JSON decoder) without hard-failing dap setup
    local ok_json, overseer_json = pcall(function()
      local ok_lazy, lazy = pcall(require, "lazy")
      if ok_lazy then
        pcall(lazy.load, { plugins = { "overseer.nvim" } })
      end
      return require("overseer.json")
    end)

    if ok_json and overseer_json and overseer_json.decode then
      vscode.json_decode = overseer_json.decode
    end

    vscode.load_launchjs()
  end

  setup_launchjs()
end

return M
