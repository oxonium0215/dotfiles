local M = {}

local cache

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

---@return table[]
function M.load()
  if cache then
    return cache
  end

  cache = {}
  local base = vim.fn.stdpath("config") .. "/lua/plugins/configs/dap/languages"
  for _, file in ipairs(vim.fn.globpath(base, "*.lua", false, true)) do
    local name = file:match("([^/]+)%.lua$")
    if name and name ~= "init" then
      local ok, mod = pcall(require, "plugins.configs.dap.languages." .. name)
      if ok and type(mod) == "table" then
        table.insert(cache, mod)
      end
    end
  end

  return cache
end

---@param modules table[]
---@return string[]
function M.ensure_list(modules)
  local ensure = {}
  for _, mod in ipairs(modules) do
    if mod.ensure then
      vim.list_extend(ensure, mod.ensure)
    end
  end
  return dedupe(ensure)
end

---@param modules table[]
---@return table<string, fun()>
function M.handlers(modules)
  local handlers = {}
  for _, mod in ipairs(modules) do
    if mod.handlers then
      for name, handler in pairs(mod.handlers) do
        handlers[name] = handler
      end
    end
  end
  return handlers
end

return M
