-- AI and productivity plugins

return {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ AI Code Assistance                                                              │
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
    {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        config = function()
            vim.defer_fn(function()
                require("plugins.configs.copilot")
            end, 100)
        end,
    },
}