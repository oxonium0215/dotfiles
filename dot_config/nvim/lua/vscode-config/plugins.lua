local pluginlist = {
    -- Essential Lua Libraries
    { "nvim-lua/plenary.nvim" }, -- Required by many plugins

    -- Syntax & Language Support
    {
        "nvim-treesitter/nvim-treesitter",
        cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
        event = "BufReadPost",
        build = ":TSUpdate",
        opts = function()
            return require("plugins.configs.treesitter")
        end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
            "windwp/nvim-autopairs",
            "hrsh7th/cmp-cmdline",        -- コマンドライン補完用
            "hrsh7th/cmp-path",           -- パス補完用
            "hrsh7th/cmp-buffer",         -- バッファ補完用
            "hrsh7th/cmp-nvim-lua",       -- Lua補完用
            "saadparwaiz1/cmp_luasnip",   -- LuaSnip用
            "hrsh7th/cmp-nvim-lsp",       -- lsp補完用
            "hrsh7th/cmp-nvim-lsp-signature-help", -- 関数
            "hrsh7th/cmp-emoji",          -- emoji用
            "hrsh7th/cmp-calc",           -- 計算用
            "ray-x/cmp-treesitter",       -- Treesitter用
            "lukas-reineke/cmp-rg",       -- ripgrep用
            "petertriho/cmp-git",
            "lukas-reineke/cmp-under-comparator", -- 補完並び替え
        },
        config = function()
            return require("plugins.configs.cmp")
        end,
    },

    -- Improved UI Inputs
    {
        "stevearc/dressing.nvim",
        init = function()
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.select(...)
            end
            vim.ui.input = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.input(...)
            end
        end,
    },

    -- Auto-pairs
    {
        "windwp/nvim-autopairs",
        opts = {
            disable_filetype = { "TelescopePrompt", "vim" },
        },
    },
}

local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(pluginlist, lazyconfig)
