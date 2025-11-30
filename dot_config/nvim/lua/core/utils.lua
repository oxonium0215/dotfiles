local M = {}

M.echo = function(str)
    vim.cmd "redraw"
    vim.api.nvim_echo({ { str, "Bold" } }, true, {})
end

local function shell_call(args)
    local output = vim.fn.system(args)
    assert(vim.v.shell_error == 0, "External call failed with error code: " .. vim.v.shell_error .. "\n" .. output)
end

M.set_mappings = function(section, extra_opts)
    local mappings = require("mappings")[section]
    if not mappings then
        error("Invalid mappings section: " .. tostring(section))
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
  local mappings = require("mappings")[section]
  if not mappings then
      error("Invalid mappings section: " .. tostring(section))
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

M.lazy = function(install_path)
    --------- lazy.nvim ---------------
    M.echo "  Installing lazy.nvim & plugins ..."
    local repo = "https://github.com/folke/lazy.nvim.git"
    shell_call { "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }
    vim.opt.rtp:prepend(install_path)

    -- install plugins
    require("plugins")
    M.echo "Setup finished!"
end

M.toggleTerm = function(direction)
    local command = ":ToggleTerm direction=" .. direction
    vim.cmd(command)
end

return M
