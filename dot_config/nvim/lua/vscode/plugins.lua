-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local pluginlist = {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Other                                                                         │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    -- Lua Library
    {"nvim-lua/popup.nvim"},
    {"nvim-lua/plenary.nvim"},
    {"kkharji/sqlite.lua"},
    {"MunifTanjim/nui.nvim"},
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ UI                                                                            │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    -- Font
    {
        "nvim-tree/nvim-web-devicons",
        enabled = function()
            return not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false"
        end
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Easymotion                                                                    │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "rlane/pounce.nvim",
        init = function()
            require("core.utils").load_mappings "pounce"
        end,
        cmd = {"Pounce", "PounceRepeat"}
    },
    {
        "phaazon/hop.nvim",
        branch = "v2",
        init = function()
            require("core.utils").load_mappings "hop"
        end,
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require "hop".setup {keys = "etovxqpdygfblzhckisuran"}
        end
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ cmp                                                                           │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "j-hui/fidget.nvim",
        tag = "legacy",
        event = "LspAttach",
        opts = {}
    },
    {
        "numToStr/Comment.nvim",
        event = {"CursorHold", "CursorHoldI"},
        keys = {
            {"gcc", mode = "n", desc = "Comment toggle current line"},
            {"gc", mode = {"n", "o"}, desc = "Comment toggle linewise"},
            {"gc", mode = "x", desc = "Comment toggle linewise (visual)"},
            {"gbc", mode = "n", desc = "Comment toggle current block"},
            {"gb", mode = {"n", "o"}, desc = "Comment toggle blockwise"},
            {"gb", mode = "x", desc = "Comment toggle blockwise (visual)"}
        },
        init = function()
            require("core.utils").load_mappings "comment"
        end,
        config = function(_, opts)
            require("Comment").setup(opts)
        end
    },
}

local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(pluginlist, lazyconfig)
