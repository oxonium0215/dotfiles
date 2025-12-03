local M = {}
local cache
local server_filetype_cache = {}

local function dedupe(list)
  local seen, result = {}, {}
  for _, item in ipairs(list) do
    if item and not seen[item] then
      seen[item] = true
      table.insert(result, item)
    end
  end
  return result
end

local function merge_requirements(target, requirements)
  if not requirements then
    return
  end

  for tool, runtime in pairs(requirements) do
    if tool and runtime then
      target[tool] = runtime
    end
  end
end

local function collect_exec_requirements(configs)
  local requirements = {}
  for _, config in pairs(configs or {}) do
    merge_requirements(requirements, config.requirements)
    if config.lsp then
      merge_requirements(requirements, config.lsp.requirements)
    end
  end
  return requirements
end

---Load per-language configs from the languages directory (cached)
---@return table<string, table>
function M.all()
  if cache then
    return cache
  end

  cache = {}
  local base = vim.fn.stdpath("config") .. "/lua/plugins/configs/lsp/languages"

  for _, file in ipairs(vim.fn.globpath(base, "*.lua", false, true)) do
    local lang = file:match("([^/]+)%.lua$")
    if lang then
      local ok, config = pcall(require, "plugins.configs.lsp.languages." .. lang)
      if ok and type(config) == "table" then
        cache[lang] = config
      end
    end
  end

  return cache
end

function M.reload()
  cache = nil
  server_filetype_cache = {}
end

local function get_server_filetypes(server)
  if server_filetype_cache[server] then
    return server_filetype_cache[server]
  end

  -- Use the config module directly to avoid the deprecated lspconfig framework lookup
  local ok_cfg, cfg = pcall(require, "lspconfig.configs." .. server)
  if ok_cfg and cfg and cfg.default_config then
    local fts = cfg.default_config.filetypes or cfg.filetypes
    if type(fts) == "table" then
      server_filetype_cache[server] = fts
      return fts
    end
  end

  return nil
end

---@param filetype string
---@return table<string, table>
function M.matching_configs(filetype)
  local matches = {}
  local all_langs = M.all()

  for name, config in pairs(all_langs) do
    if name == filetype then
      matches[name] = config
    else
      local lsp = config.lsp
      if lsp and lsp.servers then
        for _, server in ipairs(lsp.servers) do
          local fts = get_server_filetypes(server)
          if fts and vim.tbl_contains(fts, filetype) then
            matches[name] = config
            break
          end
        end
      end
    end
  end

  return matches
end

local warned_exec = {}

---@return string[]
function M.collect_servers()
  local configs = M.all()
  local servers = {}
  for _, config in pairs(configs) do
    local lsp = config.lsp
    if lsp and lsp.servers then
      vim.list_extend(servers, lsp.servers)
    end
  end
  return dedupe(servers)
end

---@return string[]
function M.collect_null_ls_sources()
  local configs = M.all()
  local requirements = collect_exec_requirements(configs)
  local sources = {}
  for _, config in pairs(configs) do
    local lsp = config.lsp
    if lsp then
      if lsp.formatters then
        vim.list_extend(sources, lsp.formatters)
      end
      if lsp.linters then
        vim.list_extend(sources, lsp.linters)
      end
    end
  end
  sources = dedupe(sources)

  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return sources
  end

  local filtered = {}
  for _, source in ipairs(sources) do
    if registry.has_package(source) then
      local req = requirements[source]
      local has_runtime = true
      if req and vim.fn.executable(req) ~= 1 then
        has_runtime = false
        if not warned_exec[source] then
          -- warned_exec[source] = true
          -- vim.schedule(function()
          --   vim.notify(
          --     string.format(
          --       "Skipping %s: missing required runtime '%s' in PATH for mason-null-ls installation.",
          --       source,
          --       req
          --     ),
          --     vim.log.levels.WARN
          --   )
          -- end)
        end
      end

      if has_runtime then
        table.insert(filtered, source)
      end
    end
  end
  return filtered
end

---@return string[]
function M.collect_parsers()
  local parsers = {}
  for _, config in pairs(M.all()) do
    if config.treesitter then
      vim.list_extend(parsers, config.treesitter)
    end
  end
  return dedupe(parsers)
end

---@return table<string, fun(): table>
function M.server_setups()
  local setups = {}
  for _, config in pairs(M.all()) do
    if config.lsp and config.lsp.setup then
      for server, setup_fn in pairs(config.lsp.setup) do
        setups[server] = setup_fn
      end
    end
  end
  return setups
end

function M.exec_requirements()
  return collect_exec_requirements(M.all())
end

return M
