-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local pluginlist = {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Other                                                                         │
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
    -- Lua Library
    { "nvim-lua/plenary.nvim" },
    { "kkharji/sqlite.lua" },
    { "MunifTanjim/nui.nvim" },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ UI                                                                            │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    -- Font
    {
        "nvim-tree/nvim-web-devicons",
        enabled = function()
            return not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false"
        end,
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Easymotion                                                                    │
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
    -- │ ∘ Filer & Terminal                                                              │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "stevearc/oil.nvim",
        keys = require("core.utils").generate_lazy_keys("oil"),
        cmd = { "Oil" },
        opts = {},
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },
}

local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(pluginlist, lazyconfig)
