-- Core utility functions for Neovim configuration

local M = {}

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ Display Utilities                                                               │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

--- Echo a message with bold formatting
---@param str string The message to display
M.echo = function(str)
    vim.cmd("redraw")
    vim.api.nvim_echo({ { str, "Bold" } }, true, {})
end

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ Keymap Utilities                                                                │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

--- Generate lazy.nvim compatible keymaps from mapping tables
---@param section string The section name from mappings table
---@return table lazy_keys Table of lazy.nvim compatible keymaps
M.generate_lazy_keys = function(section)
    local ok, mappings = pcall(require, "config.keymaps")
    if not ok or not mappings[section] then
        return {}
    end
    
    local lazy_keys = {}
    for _, mapping in ipairs(mappings[section]) do
        local mode = mapping[1]
        local lhs = mapping[2]
        local rhs = mapping[3]
        local opts = mapping[4] or {}
        
        if type(mode) == "table" then
            mode = table.concat(mode, "")
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

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ Terminal Utilities                                                              │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

--- Toggle terminal in specified direction
---@param direction string The direction for the terminal ('vertical', 'horizontal', 'float')
M.toggleTerm = function(direction)
    local command = ":ToggleTerm direction=" .. direction
    vim.cmd(command)
end

return M
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
