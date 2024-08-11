local dap = require "dap"
local dapui = require "dapui"
dofile(vim.g.base46_cache .. "dap")

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
