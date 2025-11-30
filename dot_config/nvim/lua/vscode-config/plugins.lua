-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local pluginlist = {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Other                                                                         │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        opts = {},
    },
    {
        "m4xshen/hardtime.nvim",
        event = { "BufReadPost", "BufAdd", "BufNewFile" },
        dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            disable_mouse = false,
            disabled_filetypes = { "qf", "lazy", "mason", "toggleterm" },
            max_count = 10,
        },
    },
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },

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
    -- │ ∘ Treesitter                                                                    │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        dependencies = {
            { "JoosepAlviste/nvim-ts-context-commentstring" },
            { "nvim-treesitter/nvim-treesitter-refactor", enabled = false }, -- incompatible with TS main
            { "nvim-treesitter/nvim-tree-docs", enabled = false }, -- incompatible with TS main
            { "yioneko/nvim-yati", enabled = false }, -- incompatible with TS main
        },
        build = ":TSUpdate",
        config = function()
            require("plugins.configs.treesitter").setup()
        end,
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Git stuff                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "lewis6991/gitsigns.nvim",
        ft = { "gitcommit", "diff" },
        event = { "CursorHold", "CursorHoldI" },
        init = function()
            -- load gitsigns only when a git file is opened
            vim.api.nvim_create_autocmd({ "BufRead" }, {
                group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
                callback = function()
                    vim.fn.system("git -C " .. '"' .. vim.fn.expand("%:p:h") .. '"' .. " rev-parse")
                    if vim.v.shell_error == 0 then
                        vim.api.nvim_del_augroup_by_name("GitSignsLazyLoad")
                        vim.schedule(function()
                            require("lazy").load({ plugins = { "gitsigns.nvim" } })
                        end)
                    end
                end,
            })
        end,
        opts = function()
            return require("plugins.configs.others").gitsigns
        end,
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ AI tools                                                                      │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "olimorris/codecompanion.nvim",
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionAction" },
        keys = require("core.utils").generate_lazy_keys("codecompanion"),
        opts = function()
            return require("plugins.configs.codecompanion")
        end,
        config = function(_, opts)
            require("plugins.codecompanion.fidget-spinner"):init()
            require("codecompanion").setup(opts)
        end,
    },
}

local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(pluginlist, lazyconfig)
