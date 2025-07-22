-- Development tools and debugging plugins

return {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Debug Adapter Protocol                                                         │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "mfussenegger/nvim-dap",
        keys = require("core.utils").generate_lazy_keys("dap"),
        dependencies = {
            -- Beautiful debugger UI
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
            },
            -- Install debug adapters
            "mason-org/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
        },
        config = function()
            require("plugins.configs.dap")
        end,
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Task Runner                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "stevearc/overseer.nvim",
        keys = require("core.utils").generate_lazy_keys("overseer"),
        cmd = { "OverseerRun" },
        opts = {
            templates = { "builtin", "user.cpp_build", "user.run_script" },
            strategy = { "toggleterm" },
        },
        dependencies = { "mfussenegger/nvim-dap" },
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Performance Monitoring                                                          │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        config = function()
            vim.g.startuptime_tries = 100
        end,
    },
}