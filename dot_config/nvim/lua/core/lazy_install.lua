local M = {}

local install_in_progress = {}
local warned_runtime = {}
local registry_ready = false
local registry_checked = false
local registry_refreshing = false
local registry_waiters = {}

local function get_registry()
  return require("mason-registry")
end

local function run_registry_waiters(ok)
  local waiters = registry_waiters
  registry_waiters = {}
  for _, cb in ipairs(waiters) do
    if cb then
      pcall(cb, ok)
    end
  end
end

local function ensure_registry(callback)
  local registry = get_registry()
  if not registry_checked then
    registry_ready = registry.sources:is_all_installed()
    registry_checked = true
  end

  if registry_ready then
    if callback then
      callback(true)
    end
    return
  end

  if callback then
    table.insert(registry_waiters, callback)
  end

  if registry_refreshing then
    return
  end

  registry_refreshing = true
  registry.refresh(function(success)
    registry_ready = success ~= false and registry.sources:is_all_installed()
    registry_refreshing = false
    run_registry_waiters(registry_ready)

    if not registry_ready then
      vim.schedule(function()
        vim.notify("Mason registry refresh failed; tool auto-install skipped.", vim.log.levels.WARN)
      end)
    end
  end)
end

local function dedupe(list)
  local seen, result = {}, {}
  for _, item in ipairs(list or {}) do
    if item and not seen[item] then
      seen[item] = true
      table.insert(result, item)
    end
  end
  return result
end

local function notify_completion(pkg_name, success)
  local level = success and vim.log.levels.INFO or vim.log.levels.WARN
  local message = success and ("Installed tool: " .. pkg_name) or ("Tool installation failed: " .. pkg_name)
  vim.notify(message, level)
end

local function complete_install(pkg_name, success)
  local state = install_in_progress[pkg_name]
  install_in_progress[pkg_name] = nil

  notify_completion(pkg_name, success)

  if state then
    for _, cb in ipairs(state.waiters) do
      if cb then
        cb(success)
      end
    end
  end
end

local function install_package(pkg_name, callback)
  local registry = get_registry()
  if registry.is_installed(pkg_name) then
    if callback then
      callback(true)
    end
    return
  end

  local state = install_in_progress[pkg_name]
  if state then
    if callback then
      table.insert(state.waiters, callback)
    end
    return
  end

  local ok, pkg = pcall(registry.get_package, pkg_name)
  if not ok then
    vim.notify("Package not found in Mason registry: " .. pkg_name, vim.log.levels.WARN)
    if callback then
      callback(false)
    end
    return
  end

  local waiters = {}
  if callback then
    table.insert(waiters, callback)
  end
  install_in_progress[pkg_name] = { waiters = waiters }

  local ok_install, handle = pcall(function()
    return pkg:install()
  end)

  if not ok_install or not handle then
    complete_install(pkg_name, false)
    return
  end

  handle:once("closed", function()
    complete_install(pkg_name, pkg:is_installed())
  end)
end

---@param packages string[]
---@param callback? fun(results: table<string, boolean>)
function M.install(packages, callback)
  ensure_registry(function(ok)
    if not ok then
      if callback then
        callback({})
      end
      return
    end

    local registry = get_registry()
    local unique = dedupe(packages)
    if #unique == 0 then
      if callback then
        callback({})
      end
      return
    end

    local pending = 0
    local results = {}
    local announced = {}

    local function mark_done(name, ok)
      results[name] = ok
      pending = pending - 1
      if pending == 0 and callback then
        callback(results)
      end
    end

    for _, pkg_name in ipairs(unique) do
      if registry.is_installed(pkg_name) then
        results[pkg_name] = true
      else
        pending = pending + 1
        if not install_in_progress[pkg_name] then
          table.insert(announced, pkg_name)
        end
        install_package(pkg_name, function(success)
          mark_done(pkg_name, success ~= false)
        end)
      end
    end

    if #announced > 0 then
      vim.notify("Installing tools: " .. table.concat(announced, ", "), vim.log.levels.INFO)
    end

    if pending == 0 and callback then
      callback(results)
    end
  end)
end

---@param filetype string
---@return string[]
function M.get_tools(filetype)
  local registry = get_registry()
  local tools = {}
  local seen = {}

  local function add_tool(name)
    if name and not seen[name] then
      seen[name] = true
      table.insert(tools, name)
    end
  end

  -- Helper to resolve LSP names
  local function resolve_lsp(name)
    local ok, mappings = pcall(require, "mason-lspconfig.mappings")
    if ok and mappings.get_all then
      local map = mappings.get_all().lspconfig_to_package or {}
      return map[name] or name
    end
    return name
  end

  -- Collect LSP servers and formatters
  local lsp_langs = require("plugins.configs.lsp.langs")
  local exec_requirements = lsp_langs.exec_requirements()
  local function has_runtime(name, alt, ft)
    local req = exec_requirements[name] or (alt and exec_requirements[alt])
    if not req then
      return true
    end

    local ok = vim.fn.executable(req) == 1
    if not ok then
      local key = (alt or name or "") .. "::" .. req
      if not warned_runtime[key] then
        warned_runtime[key] = true
        vim.schedule(function()
          vim.notify(
            string.format("Missing runtime '%s' for %s (%s); skipping auto-install.", req, alt or name, ft or "tool"),
            vim.log.levels.WARN
          )
        end)
      end
    end
    return ok
  end

  for _, config in pairs(lsp_langs.matching_configs(filetype)) do
    if config.lsp then
      if config.lsp.servers then
        for _, server in ipairs(config.lsp.servers) do
          local pkg_name = resolve_lsp(server)
          if registry.has_package(pkg_name) and has_runtime(server, pkg_name, filetype) then
            add_tool(pkg_name)
          end
        end
      end
      if config.lsp.formatters then
        for _, tool in ipairs(config.lsp.formatters) do
          if registry.has_package(tool) and has_runtime(tool, nil, filetype) then
            add_tool(tool)
          end
        end
      end
      if config.lsp.linters then
        for _, tool in ipairs(config.lsp.linters) do
          if registry.has_package(tool) and has_runtime(tool, nil, filetype) then
            add_tool(tool)
          end
        end
      end
    end
  end

  -- Collect DAP adapters
  local dap_langs = require("plugins.configs.dap.languages")
  local dap_modules = dap_langs.load()
  for _, mod in ipairs(dap_modules) do
    if mod.filetypes and vim.tbl_contains(mod.filetypes, filetype) then
      if mod.ensure then
        for _, tool in ipairs(mod.ensure) do
          if registry.has_package(tool) then
            add_tool(tool)
          end
        end
      end
    end
  end

  return tools
end

---@param filetype string
function M.ensure_for_filetype(filetype)
  if not filetype or filetype == "" then
    return
  end

  ensure_registry(function(ok)
    if not ok then
      return
    end

    local tools = M.get_tools(filetype)
    if #tools > 0 then
      M.install(tools, function()
        -- Optional: Trigger events or re-check capabilities
      end)
    end
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("LazyInstallTools", { clear = true })

  local function ensure_current(bufnr)
    local buf = bufnr or 0
    local bo = vim.bo[buf]
    local ft = bo.filetype

    if ft == "" or bo.buftype == "prompt" then
      return
    end

    -- Prevent re-entrancy / nesting loops on FileType
    if vim.b[buf].__lazy_install_running then
      return
    end
    vim.b[buf].__lazy_install_running = true

    vim.schedule(function()
      pcall(M.ensure_for_filetype, ft)
      if vim.api.nvim_buf_is_valid(buf) then
        vim.b[buf].__lazy_install_running = nil
      end
    end)
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(opts)
      ensure_current(opts.buf)
    end,
  })

  -- vim.api.nvim_create_autocmd("VimEnter", {
  --   group = group,
  --   callback = function()
  --     -- Defer the initial check by 500ms to allow UI to render first
  --     vim.defer_fn(function()
  --       if vim.api.nvim_buf_is_valid(0) then
  --         ensure_current(0)
  --       end
  --     end, 500)
  --   end,
  -- })
end

return M