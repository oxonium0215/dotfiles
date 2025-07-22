-- VSCode-compatible plugins
-- Minimal plugin set for use within VSCode

local plugins = {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Core Libraries                                                                  │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Motion & Navigation                                                             │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "rlane/pounce.nvim",
        keys = require("core.utils").generate_lazy_keys("pounce"),
        cmd = { "Pounce", "PounceRepeat" },
    },
    {
        "phaazon/hop.nvim",
        keys = require("core.utils").generate_lazy_keys("hop"),
        branch = "v2",
        opts = {},
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ File Management                                                                 │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "stevearc/oil.nvim",
        keys = require("core.utils").generate_lazy_keys("oil"),
        cmd = { "Oil" },
        opts = {},
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Productivity                                                                    │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "m4xshen/hardtime.nvim",
        event = { "BufReadPost", "BufAdd", "BufNewFile" },
        dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            disable_mouse = false,
            disabled_filetypes = { "qf", "alpha", "NvimTree", "lazy", "mason", "oil", "toggleterm" },
            max_count = 10,
        },
    },
}

-- Load lazy.nvim configuration
local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(plugins, lazyconfig)