-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local pluginlist = {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Other                                                                         │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "yorickpeterse/nvim-window",
        init = function()
            require("core.utils").load_mappings "nvimwindow"
        end
    },
    {
        "m4xshen/hardtime.nvim",
        event = {"BufReadPost", "BufAdd", "BufNewFile"},
        dependencies = {"MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim"},
        opts = {
            disable_mouse = false,
            disabled_filetypes = {"qf", "alpha", "NvimTree", "lazy", "mason", "oil", "toggleterm"},
            max_count = 10,
        }
    },
    -- Lua Library
    {"nvim-lua/popup.nvim"},
    {"nvim-lua/plenary.nvim"},
    {"kkharji/sqlite.lua"},
    {"MunifTanjim/nui.nvim"},
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ UI                                                                            │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    -- Notify
    {
        "vigoux/notifier.nvim",
        event = "VeryLazy",
        config = function()
            require "notifier".setup {}
        end
    },
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
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Telescope                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            {
                "nvim-lua/plenary.nvim"
            },
            {
                "Allianaab2m/telescope-kensaku.nvim",
                config = function()
                    require("telescope").load_extension("kensaku") -- :Telescope kensaku
                end
            },
            {
                "nvim-treesitter/nvim-treesitter"
            },
            {
                "nvim-telescope/telescope-github.nvim",
                config = function()
                    require("telescope").load_extension("gh")
                end
            },
            {
                "nvim-telescope/telescope-ui-select.nvim",
                config = function()
                    require("telescope").load_extension("ui-select")
                end
            },
            {
                "LinArcX/telescope-changes.nvim",
                config = function()
                    require("telescope").load_extension("changes")
                end
            },
            {
                "nvim-telescope/telescope-live-grep-args.nvim",
                config = function()
                    require("telescope").load_extension("live_grep_args")
                end
            },
            {
                "nvim-telescope/telescope-smart-history.nvim",
                config = function()
                    require("telescope").load_extension("smart_history")
                end,
                build = function()
                    os.execute("mkdir -p " .. vim.fn.stdpath("state") .. "databases/")
                end
            },
            {
                "nvim-telescope/telescope-symbols.nvim"
            },
            {
                "debugloop/telescope-undo.nvim",
                config = function()
                    require("telescope").load_extension("undo")
                end
            }
        },
        cmd = "Telescope",
        init = function()
            require("core.utils").load_mappings "telescope"
        end,
        opts = function()
            return require "plugins.configs.telescope"
        end,
        config = function(_, opts)
            local telescope = require "telescope"
            telescope.setup(opts)

            -- load extensions
            for _, ext in ipairs(opts.extensions_list) do
                telescope.load_extension(ext)
            end
        end
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Filer & Terminal                                                              │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
}

local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(pluginlist, lazyconfig)
