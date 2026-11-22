local M = {}

M.ensure = { "debugpy" }
M.filetypes = { "python" }

local function configure(dap)
  dap.adapters.python = function(cb, config)
    if config.request == "attach" then
      local port = (config.connect or config).port
      local host = (config.connect or config).host or "127.0.0.1"
      cb({
        type = "server",
        port = assert(port, "`connect.port` is required for a python `attach` configuration"),
        host = host,
        options = {
          source_filetype = "python",
        },
      })
    else
      cb({
        type = "executable",
        command = vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python",
        args = { "-m", "debugpy.adapter" },
        options = {
          source_filetype = "python",
        },
      })
    end
  end

  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      pythonPath = function()
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
          return cwd .. "/venv/bin/python"
        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          return cwd .. "/.venv/bin/python"
        elseif vim.fn.executable(cwd .. "/venv/Scripts/python.exe") == 1 then
          return cwd .. "/venv/Scripts/python.exe"
        elseif vim.fn.executable(cwd .. "/.venv/Scripts/python.exe") == 1 then
          return cwd .. "/.venv/Scripts/python.exe"
        elseif vim.fn.exepath("python3") ~= "" then
          return vim.fn.exepath("python3")
        else
          return "python"
        end
      end,
    },
  }
end

M.handlers = {
  python = function()
    configure(require("dap"))
  end,
}

return M
