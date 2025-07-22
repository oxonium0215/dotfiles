-- Plugin configuration for Neovim
-- Organized by functionality for better maintainability

local plugins = {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Core Libraries                                                                  │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    { "nvim-lua/plenary.nvim" },
    { "nvim-lua/popup.nvim" },
    { "kkharji/sqlite.lua" },
    { "MunifTanjim/nui.nvim" },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ UI & Appearance                                                                 │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.ui"),

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Editor Enhancements                                                             │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.editor"),

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ LSP & Completion                                                                │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.lsp"),

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Git Integration                                                                 │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.git"),

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ File Management & Navigation                                                    │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.navigation"),

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Language-specific                                                               │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.languages"),

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ AI & Productivity                                                               │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.ai"),

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Development Tools                                                               │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.dev"),

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Utilities                                                                       │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    require("plugins.utils"),
}

-- Flatten the plugin table
local flat_plugins = {}
for _, plugin_group in ipairs(plugins) do
    if type(plugin_group) == "table" and plugin_group[1] then
        -- Single plugin
        table.insert(flat_plugins, plugin_group)
    elseif type(plugin_group) == "table" then
        -- Plugin group
        for _, plugin in ipairs(plugin_group) do
            table.insert(flat_plugins, plugin)
        end
    end
end

-- Load lazy.nvim configuration and setup
local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(flat_plugins, lazyconfig)