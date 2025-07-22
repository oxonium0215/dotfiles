-- File management and navigation plugins

return {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ File Explorer                                                                   │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-tree/nvim-tree.lua",
        keys = require("core.utils").generate_lazy_keys("nvimtree"),
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        config = function()
            require("plugins.configs.nvim-tree")
        end,
    },
    {
        "stevearc/oil.nvim",
        keys = require("core.utils").generate_lazy_keys("oil"),
        cmd = { "Oil" },
        opts = function()
            return require("plugins.configs.oil")
        end,
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Fuzzy Finder                                                                    │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            {
                "Allianaab2m/telescope-kensaku.nvim",
                config = function()
                    require("telescope").load_extension("kensaku")
                end,
            },
            { "nvim-treesitter/nvim-treesitter" },
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                config = function()
                    require("telescope").load_extension("fzf")
                end,
            },
            {
                "nvim-telescope/telescope-ui-select.nvim",
                config = function()
                    require("telescope").load_extension("ui-select")
                end,
            },
        },
        keys = require("core.utils").generate_lazy_keys("telescope"),
        cmd = "Telescope",
        config = function()
            require("plugins.configs.telescope")
        end,
    },

    -- Alternative fuzzy finder (commented out by default)
    -- {
    --     "ibhagwan/fzf-lua",
    --     dependencies = { "nvim-tree/nvim-web-devicons" },
    --     keys = require("core.utils").generate_lazy_keys("fzf"),
    --     opts = function()
    --         return require("plugins.configs.fzf")
    --     end,
    -- },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Terminal                                                                        │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "akinsho/toggleterm.nvim",
        keys = require("core.utils").generate_lazy_keys("toggleterm"),
        cmd = { "ToggleTerm", "TermExec" },
        opts = function()
            return require("plugins.configs.toggleterm")
        end,
    },
}