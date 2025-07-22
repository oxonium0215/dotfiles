-- LSP and completion plugins

return {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ LSP Configuration                                                               │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = function()
            return require("plugins.configs.mason")
        end,
        config = function(_, opts)
            require("mason").setup(opts)
            vim.g.mason_binaries_list = opts.ensure_installed
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        event = "BufReadPre",
        config = function()
            require("plugins.configs.lsp").setup()
        end,
        dependencies = {
            "neovim/nvim-lspconfig",
            "mason.nvim",
            "jay-babu/mason-null-ls.nvim",
            "folke/neoconf.nvim",
            "folke/neodev.nvim",
        },
    },
    {
        "jay-babu/mason-null-ls.nvim",
        event = "BufReadPre",
        dependencies = {
            "mason-org/mason.nvim",
            "nvimtools/none-ls.nvim",
        },
        config = function()
            require("mason-null-ls").setup({
                automatic_installation = true,
                handlers = {},
            })
        end,
    },
    {
        "nvimtools/none-ls.nvim",
        event = "BufReadPre",
        config = function()
            require("plugins.configs.null-ls")
        end,
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Completion                                                                      │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            {
                -- Snippet engine
                "L3MON4D3/LuaSnip",
                dependencies = "rafamadriz/friendly-snippets",
                opts = {
                    history = true,
                    updateevents = "TextChanged,TextChangedI",
                },
                config = function(_, opts)
                    require("plugins.configs.others").luasnip(opts)
                end,
            },
            {
                -- Auto-pairing
                "windwp/nvim-autopairs",
                opts = {
                    fast_wrap = {},
                    disable_filetype = { "TelescopePrompt", "vim" },
                },
                config = function(_, opts)
                    require("nvim-autopairs").setup(opts)
                    -- Setup cmp for autopairs
                    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                    require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
                end,
            },
            -- Completion sources
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lua",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-emoji",
            "hrsh7th/cmp-calc",
            "ray-x/cmp-treesitter",
            "lukas-reineke/cmp-rg",
            "petertriho/cmp-git",
            "lukas-reineke/cmp-under-comparator",
        },
        config = function()
            return require("plugins.configs.cmp")
        end,
    },
    {
        "onsails/lspkind-nvim",
        config = function()
            require("plugins.configs.lspkind")
        end,
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Diagnostics                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "folke/trouble.nvim",
        keys = require("core.utils").generate_lazy_keys("trouble"),
        opts = function()
            return require("plugins.configs.trouble")
        end,
        cmd = { "Trouble" },
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Performance                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = { "CursorHold", "CursorHoldI" },
        opts = {},
    },
}