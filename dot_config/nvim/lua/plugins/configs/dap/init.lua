local M = {}

local mason_dap = require("mason-nvim-dap")
local languages = require("plugins.configs.dap.languages")

local function setup_signs()
  local signs = {
    DapBreakpoint = { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" },
    DapBreakpointCondition = { text = "", texthl = "DapBreakpointCondition", linehl = "", numhl = "" },
    DapLogPoint = { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" },
    DapStopped = { text = "", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" },
    DapBreakpointRejected = { text = "", texthl = "DapBreakpointRejected", linehl = "", numhl = "" },
  }
  for name, sign in pairs(signs) do
    vim.fn.sign_define(name, sign)
  end

  vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" })
  vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#61afef" })
  vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#98c379" })
  vim.api.nvim_set_hl(0, "DapStopped", { fg = "#e5c07b" })
  vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2c313a" })
end

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

local function setup_vscode_launchjs()
  local ok, vscode = pcall(require, "dap.ext.vscode")
  if ok then
    pcall(vscode.load_launchjs, nil, {
      codelldb = { "c", "cpp", "rust" },
      debugpy = { "python" },
      delve = { "go" },
    })
  end
end

function M.setup()
  local dap = require("dap")
  local dapui = require("dapui")
  local lang_modules = languages.load()

  setup_signs()
  setup_mason_handlers(lang_modules)

  for _, mod in ipairs(lang_modules) do
    if type(mod.setup) == "function" then
      mod.setup(dap)
    end
  end

  local ok_vt, dap_vt = pcall(require, "nvim-dap-virtual-text")
  if ok_vt then
    dap_vt.setup({
      commented = true,
      highlight_changed_variables = true,
    })
  end

  setup_ui(dap, dapui)
  setup_vscode_launchjs()
end

return M
