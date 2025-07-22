-- Editor enhancement plugins

return {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Treesitter                                                                      │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-treesitter/nvim-treesitter",
        cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
        event = "BufReadPost",
        dependencies = {
            { "JoosepAlviste/nvim-ts-context-commentstring" },
            { "nvim-treesitter/nvim-treesitter-refactor" },
            { "nvim-treesitter/nvim-tree-docs" },
            { "yioneko/nvim-yati" },
        },
        build = ":TSUpdate",
        opts = function()
            return require("plugins.configs.treesitter")
        end,
    },

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
    -- │ Search & Replace                                                                │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "VonHeikemen/searchbox.nvim",
        keys = require("core.utils").generate_lazy_keys("searchbox"),
        cmd = { "SearchBoxIncSearch", "SearchBoxReplace" },
        dependencies = { "MunifTanjim/nui.nvim" },
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Window Management                                                               │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "yorickpeterse/nvim-window",
        keys = require("core.utils").generate_lazy_keys("nvimwindow"),
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Session Management                                                              │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "jedrzejboczar/possession.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = {
            "PossessionSave",
            "PossessionLoad",
            "PossessionRename",
            "PossessionClose",
            "PossessionDelete",
            "PossessionShow",
            "PossessionList",
            "PossessionMigrate",
        },
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

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Clipboard                                                                       │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "EtiamNullam/deferred-clipboard.nvim",
        event = "VeryLazy",
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Markdown                                                                        │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "markdown.mdx", "Avante", "codecompanion" },
        opts = { "markdown", "markdown.mdx", "Avante", "codecompanion" },
    },
}