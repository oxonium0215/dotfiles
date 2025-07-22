-- UI and appearance plugins

return {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Colorscheme                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "darker",
            lualine = {},
        },
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Icons                                                                           │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-tree/nvim-web-devicons",
        enabled = function()
            return not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false"
        end,
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Startup Screen                                                                  │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "goolord/alpha-nvim",
        event = "BufWinEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("plugins.configs.alpha")
        end,
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Statusline & Bufferline                                                        │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-lualine/lualine.nvim",
        event = { "BufReadPost", "BufAdd", "BufNewFile" },
        config = function()
            require("plugins.configs.lualine")
        end,
    },
    {
        "akinsho/bufferline.nvim",
        event = { "BufReadPost", "BufAdd", "BufNewFile" },
        keys = require("core.utils").generate_lazy_keys("bufferline"),
        opts = function()
            return require("plugins.configs.bufferline")
        end,
        dependencies = { "famiu/bufdelete.nvim" },
        config = function(_, opts)
            require("bufferline").setup(opts)
            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd("BufAdd", {
                callback = function()
                    vim.schedule(function()
                        pcall(nvim_bufferline)
                    end)
                end,
            })
        end,
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Visual Enhancements                                                             │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "brenoprata10/nvim-highlight-colors",
        event = "BufReadPost",
        opts = {
            render = "background",
            virtual_symbol = "",
            enable_tailwind = true,
        },
    },
    {
        "shellRaining/hlchunk.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = function()
            return require("plugins.configs.hlchunk")
        end,
    },
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufReadPost",
        config = function()
            require("plugins.configs.rainbow-delimiters")
            -- Patch for treesitter issue
            if vim.fn.expand("%:p") ~= "" then
                vim.cmd.edit({ bang = true })
            end
        end,
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Notifications & UI Improvements                                                │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "rcarriga/nvim-notify",
        keys = require("core.utils").generate_lazy_keys("notify"),
        opts = {
            stages = "static",
            timeout = 7000,
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
                return math.floor(vim.o.columns * 0.75)
            end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
        },
        init = function()
            vim.notify = vim.schedule_wrap(require("notify"))
        end,
    },
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {
            notification = {},
        },
    },
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
}