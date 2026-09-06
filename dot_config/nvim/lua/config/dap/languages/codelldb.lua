local M = {}

local mason_registry = require("mason-registry")
local mason_settings = require("mason.settings")
local mason_path = require("mason-core.path")

M.ensure = { "codelldb" }
M.filetypes = { "c", "cpp", "rust" }

local function get_binary_path()
  local file = vim.fn.expand("%:p")
  local outfile = vim.fn.expand("%:p:r")
  if vim.fn.has("win32") == 1 then
    outfile = outfile .. ".exe"
  end

  -- If compiled binary exists and is newer or present, use it
  if vim.fn.filereadable(outfile) == 1 then
    return outfile
  end

  -- Check for Cargo project target/debug
  local root = vim.fs.root(0, "Cargo.toml")
  if root then
    local pkg_name = vim.fn.fnamemodify(root, ":t")
    local cargo_bin = root .. "/target/debug/" .. pkg_name
    if vim.fn.has("win32") == 1 then
      cargo_bin = cargo_bin .. ".exe"
    end
    if vim.fn.filereadable(cargo_bin) == 1 then
      return cargo_bin
    end
  end

  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

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
    name = "Launch executable",
    type = "codelldb",
    request = "launch",
    program = get_binary_path,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    console = "integratedTerminal",
  }

  dap.configurations.cpp = { default_cpp }
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = {
    {
      name = "Launch Rust binary",
      type = "codelldb",
      request = "launch",
      program = get_binary_path,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      console = "integratedTerminal",
    },
  }
end

M.handlers = {
  codelldb = function()
    configure(require("dap"))
  end,
}

return M
