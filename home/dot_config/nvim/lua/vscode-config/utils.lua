local M = {}

M.set_mappings = function(section, extra_opts)
  local ok, mappings_mod = pcall(require, "vscode-config.mappings")
  local mappings = ok and mappings_mod and mappings_mod[section]
  if not mappings then
    return
  end
  for _, mapping in ipairs(mappings) do
    local mode, lhs, rhs, opts = unpack(mapping)
    if extra_opts then
      opts = vim.tbl_deep_extend("force", opts or {}, extra_opts)
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

M.generate_lazy_keys = function(section)
  local ok, mappings_mod = pcall(require, "vscode-config.mappings")
  local mappings = ok and mappings_mod and mappings_mod[section]
  if not mappings then
    return {}
  end
  local lazy_keys = {}
  for _, mapping in ipairs(mappings) do
    local mode = mapping[1]
    local lhs = mapping[2]
    local rhs = mapping[3]
    local opts = mapping[4] or {}
    if type(mode) == "table" then
      mode = table.concat(mode, "")
    end
    if type(rhs) == "function" then
      local fn = rhs
      rhs = function(...)
        return fn(...)
      end
    end
    local lazy_key = {
      lhs,
      rhs,
      mode = mode,
    }
    for key, value in pairs(opts) do
      lazy_key[key] = value
    end
    table.insert(lazy_keys, lazy_key)
  end
  return lazy_keys
end

return M
