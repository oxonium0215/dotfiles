local dap = require "dap"
local dapui = require "dapui"

local opts = {
    require("mason-nvim-dap").setup {
        automatic_setup = true,
        handlers = {},
        ensure_installed = {}
    }
}

dap.adapters = {
    codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
            command = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb',
            args = {'--port', '${port}'}
        }
    }
}

dap.configurations = {
    cpp = {
        {
            name = 'Launch file',
            type = 'codelldb',
            request = 'launch',
            program = function()
                return vim.fn.input('Path to executable: ', vim.fn.expand('%:p:h') .. '/main', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            console = 'integratedTerminal',
        }
    }
}

vim.keymap.set("n", "<F5>", dap.continue, {desc = "Debug: Start/Continue"})
vim.keymap.set("n", "<F1>", dap.step_into, {desc = "Debug: Step Into"})
vim.keymap.set("n", "<F2>", dap.step_over, {desc = "Debug: Step Over"})
vim.keymap.set("n", "<F3>", dap.step_out, {desc = "Debug: Step Out"})
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, {desc = "Debug: Toggle Breakpoint"})
vim.keymap.set(
    "n",
    "<leader>B",
    function()
        dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
    end,
    {desc = "Debug: Set Breakpoint"}
)

dapui.setup {
    icons = {expanded = "▾", collapsed = "▸", current_frame = "*"},
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
            disconnect = ""
        }
    }
}

vim.keymap.set("n", "<F7>", dapui.toggle, {desc = "Debug: See last session result."})

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close
require("dap.ext.vscode").json_decode = require("overseer.json").decode
require("dap.ext.vscode").load_launchjs()

return opts
