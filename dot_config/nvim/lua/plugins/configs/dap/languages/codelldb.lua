local M = {}

local mason_registry = require("mason-registry")
local mason_settings = require("mason.settings")
local mason_path = require("mason-core.path")

M.ensure = { "codelldb" }
M.filetypes = { "c", "cpp", "rust" }

local function configure(dap)
  local ok, codelldb = pcall(mason_registry.get_package, "codelldb")
  if not ok then
    return
  end

  if not codelldb:is_installed() then
    codelldb:install():once("closed", function()
      configure(dap)
    end)
    return
  end

  local adapter = mason_path.concat({
    mason_settings.current.install_root_dir,
    "packages",
    "codelldb",
    "extension",
    "adapter",
    "codelldb",
  })
  if vim.fn.filereadable(adapter) == 0 then
    vim.notify("codelldb adapter not found at " .. adapter, vim.log.levels.WARN)
    return
  end

  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = adapter,
      args = { "--port", "${port}" },
    },
  }

  local default_cpp = {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    console = "integratedTerminal",
  }

  dap.configurations.cpp = { default_cpp }
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
end

M.handlers = {
  codelldb = function()
    configure(require("dap"))
  end,
}

return M
