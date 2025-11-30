local M = {}

local cache

M.exec_requirements = {
  gopls = "go",
  gofumpt = "go",
  csharpier = "dotnet",
  ["r_language_server"] = "R",
  ["r-languageserver"] = "R",
}

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

local function has_exec(name)
  local req = M.exec_requirements[name]
  if not req then
    return true
  end
  return vim.fn.executable(req) == 1
end

local warned_exec = {}

---@return string[]
function M.collect_servers()
  local servers = {}
  for _, config in pairs(M.all()) do
    local lsp = config.lsp
    if lsp and lsp.servers then
      vim.list_extend(servers, lsp.servers)
    end
  end
  servers = dedupe(servers)
  servers = vim.tbl_filter(has_exec, servers)
  return servers
end

---@return string[]
function M.collect_null_ls_sources()
  local sources = {}
  for _, config in pairs(M.all()) do
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
      local req = M.exec_requirements[source]
      local has_runtime = true
      if req and vim.fn.executable(req) ~= 1 then
        has_runtime = false
        if not warned_exec[source] then
          warned_exec[source] = true
          vim.schedule(function()
            vim.notify(
              string.format(
                "Skipping %s: missing required runtime '%s' in PATH for mason-null-ls installation.",
                source,
                req
              ),
              vim.log.levels.WARN
            )
          end)
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

return M
