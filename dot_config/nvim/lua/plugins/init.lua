-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local pluginlist = {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Other                                                                         │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        config = function()
            vim.g.startuptime_tries = 100
        end,
    },
    {
        "EtiamNullam/deferred-clipboard.nvim",
        event = "VeryLazy",
    },
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
    {
        "yorickpeterse/nvim-window",
        keys = require("core.utils").generate_lazy_keys("nvimwindow"),
    },
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
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "markdown.mdx", "Avante", "codecompanion" },
        opts = { "markdown", "markdown.mdx", "Avante", "codecompanion" },
    },
    -- Lua Library
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },
    { "kkharji/sqlite.lua" },
    { "MunifTanjim/nui.nvim" },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ LaTeX                                                                         │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "lervag/vimtex",
        ft = { "tex", "bib" },
        keys = require("core.utils").generate_lazy_keys("vimtex"),
        config = function()
            require("plugins.configs.vimtex")
        end,
    },
    {
        "micangl/cmp-vimtex",
        ft = "tex",
        dependencies = { "hrsh7th/nvim-cmp", "lervag/vimtex" },
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ UI                                                                            │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    -- Startup screen
    {
        "goolord/alpha-nvim",
        event = "BufWinEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("plugins.configs.alpha")
        end,
    },
    -- Search
    {
        "VonHeikemen/searchbox.nvim",
        keys = require("core.utils").generate_lazy_keys("searchbox"),
        cmd = { "SearchBoxIncSearch", "SearchBoxReplace" },
        dependencies = { "MunifTanjim/nui.nvim" },
    },
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
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.select(...)
            end
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.input = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.input(...)
            end
        end,
    },
    -- Cmdline
    --[[
    {
        "VonHeikemen/fine-cmdline.nvim",
        keys = require("mappings").cmdline,
        cmd = { "FineCmdline" },
        config = function()
            require('fine-cmdline').setup {
                popup = {
                    position = {
                        row = '50%',
                        col = '50%'
                    }
                }
            }
        end,
        dependencies = {"MunifTanjim/nui.nvim"},
    },
    ]]
    -- Font
    {
        "nvim-tree/nvim-web-devicons",
        enabled = function()
            return not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false"
        end,
    },
    -- colorscheme
    {
        -- {"EdenEast/nightfox.nvim", event = "BufWinEnter"},
        {
            "navarasu/onedark.nvim",
            lazy = false,
            priority = 1000,
            opts = {
                --transparent = true,
                style = "darker",
                lualine = {},
            },
        },
        -- { "catppuccin/nvim", name = "catppuccin", event = "BufWinEnter" },
        -- {"Mofiqul/vscode.nvim", event = "BufWinEnter"},
        -- {"folke/tokyonight.nvim", event = "BufWinEnter"},
        -- {"olivercederborg/poimandres.nvim", event = "BufWinEnter"},
        -- {"projekt0n/github-nvim-theme", event = "BufWinEnter"},
    },
    {
        "akinsho/bufferline.nvim",
        event = { "BufReadPost", "BufAdd", "BufNewFile" },
        keys = require("core.utils").generate_lazy_keys("bufferline"),
        opts = function()
            return require("plugins.configs.bufferline")
        end,
        dependencies = {
            "famiu/bufdelete.nvim",
        },
        config = function(_, opts)
            require("bufferline").setup(opts)
            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd("BufAdd", {
                callback = function()
                    vim.schedule(function()
                        ---@diagnostic disable: undefined-global 
                        pcall(nvim_bufferline)
                    end)
                end,
            })
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = { "BufReadPost", "BufAdd", "BufNewFile" },
        dependencies = {},
        config = function()
            require("plugins.configs.lualine")
        end,
    },
    {
        "brenoprata10/nvim-highlight-colors",
        event = "BufReadPost",
        opts = {
            render = "background",
            virtual_symbol = "",
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
    -- {
    --     "lukas-reineke/indent-blankline.nvim",
    --     event = {"CursorHold", "CursorHoldI"},
    --     keys = require("core.utils").generate_lazy_keys("blankline"),
    --     main = "ibl",
    --     opts = function()
    --         require("plugins.configs.others").blankline()
    --     end,
    -- },
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
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufReadPost",
        config = function()
            require("plugins.configs.rainbow-delimiters")
            -- patch https://github.com/nvim-treesitter/nvim-treesitter/issues/1124
            if vim.fn.expand("%:p") ~= "" then
                vim.cmd.edit({ bang = true })
            end
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
    -- │ ∘ cmp                                                                           │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            {
                -- snippet plugin
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
                -- autopairing of (){}[] etc
                "windwp/nvim-autopairs",
                opts = {
                    fast_wrap = {},
                    disable_filetype = { "TelescopePrompt", "vim" },
                },
                config = function(_, opts)
                    require("nvim-autopairs").setup(opts)

                    -- setup cmp for autopairs
                    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                    require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
                end,
            },
            {
                "hrsh7th/cmp-cmdline",     -- コマンドライン補完用
                "hrsh7th/cmp-path",        -- パス補完用
                "hrsh7th/cmp-buffer",      -- バッファ補完用
                "hrsh7th/cmp-nvim-lua",    -- Lua補完用
                "saadparwaiz1/cmp_luasnip", -- LuaSnip用
                "hrsh7th/cmp-nvim-lsp",    -- lsp補完用
                "hrsh7th/cmp-nvim-lsp-signature-help", -- 関数
                "hrsh7th/cmp-emoji",       -- emoji用
                "hrsh7th/cmp-calc",        -- 計算用
                "ray-x/cmp-treesitter",    -- Treesitter用
                "lukas-reineke/cmp-rg",    -- ripgrep用
                "petertriho/cmp-git",
                "lukas-reineke/cmp-under-comparator", -- 補完並び替え
            },
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
    {
        "zbirenbaum/copilot.lua",
        -- cmd = { "Copilot" },
        event = "InsertEnter",
        config = function()
            vim.defer_fn(function()
                require("plugins.configs.copilot")
            end, 100)
        end,
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ LSP & DAP                                                                     │
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
    -- {
    --     "rachartier/tiny-inline-diagnostic.nvim",
    --     event = "VeryLazy",
    --     priority = 1000,
    --     opts = function()
    --         return require("plugins.configs.tiny-inline-diagnostic")
    --     end
    -- },
    {
        "folke/trouble.nvim",
        keys = require("core.utils").generate_lazy_keys("trouble"),
        opts = function()
            return require("plugins.configs.trouble")
        end,
        cmd = { "Trouble" },
    },
    {
        "mfussenegger/nvim-dap",
        keys = require("core.utils").generate_lazy_keys("dap"),
        dependencies = {
            -- Creates a beautiful debugger UI
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
            },
            -- Installs the debug adapters for you
            "mason-org/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
        },
        config = function()
            require("plugins.configs.dap")
        end,
    },
    {
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = { "CursorHold", "CursorHoldI" },
        opts = {},
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Fuzzy finder                                                                  │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    -- {
    --     "ibhagwan/fzf-lua",
    --     dependencies = { "nvim-tree/nvim-web-devicons" },
    --     opts = function()
    --         require("plugins.configs.fzf")
    --     end
    -- },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            {
                "nvim-lua/plenary.nvim",
            },
            {
                "Allianaab2m/telescope-kensaku.nvim",
                config = function()
                    require("telescope").load_extension("kensaku")
                end,
            },
            {
                "nvim-treesitter/nvim-treesitter",
            },
            {
                "nvim-telescope/telescope-github.nvim",
                config = function()
                    require("telescope").load_extension("gh")
                end,
            },
            {
                "nvim-telescope/telescope-ui-select.nvim",
                config = function()
                    require("telescope").load_extension("ui-select")
                end,
            },
            {
                "LinArcX/telescope-changes.nvim",
                config = function()
                    require("telescope").load_extension("changes")
                end,
            },
            {
                "nvim-telescope/telescope-live-grep-args.nvim",
                config = function()
                    require("telescope").load_extension("live_grep_args")
                end,
            },
            {
                "nvim-telescope/telescope-smart-history.nvim",
                config = function()
                    require("telescope").load_extension("smart_history")
                end,
                build = function()
                    os.execute("mkdir -p " .. vim.fn.stdpath("state") .. "databases/")
                end,
            },
            {
                "nvim-telescope/telescope-symbols.nvim",
            },
            {
                "debugloop/telescope-undo.nvim",
                config = function()
                    require("telescope").load_extension("undo")
                end,
            },
        },
        cmd = "Telescope",
        keys = require("core.utils").generate_lazy_keys("telescope"),
        opts = function()
            return require("plugins.configs.telescope")
        end,
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            -- load extensions
            for _, ext in ipairs(opts.extensions_list) do
                telescope.load_extension(ext)
            end
        end,
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Filer & Terminal                                                              │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-tree/nvim-tree.lua",
        keys = require("core.utils").generate_lazy_keys("nvimtree"),
        cmd = {
            "NvimTreeToggle",
            "NvimTreeOpen",
            "NvimTreeFindFile",
            "NvimTreeFindFileToggle",
            "NvimTreeRefresh",
        },
        opts = function()
            return require("plugins.configs.nvim-tree")
        end,
    },
    {
        "stevearc/oil.nvim",
        keys = require("core.utils").generate_lazy_keys("oil"),
        cmd = { "Oil" },
        opts = require("plugins.configs.oil"),
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },
    {
        "akinsho/toggleterm.nvim",
        keys = require("core.utils").generate_lazy_keys("toggleterm"),
        cmd = {
            "ToggleTerm",
            "ToggleTermSetName",
            "ToggleTermToggleAll",
            "ToggleTermSendVisualLines",
            "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualSelection",
        },
        opts = require("plugins.configs.toggleterm"),
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Code Runner & Live server                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "michaelb/sniprun",
        branch = "master",
        cmd = { "SnipRun" },
        build = "sh install.sh",
        -- do 'sh install.sh 1' if you want to force compile locally
        -- (instead of fetching a binary from the github release). Requires Rust >= 1.65
        opts = {
            display = { "Terminal", "NvimNotifyErr" },
            display_options = {
                terminal_scrollback = vim.o.scrollback, -- change terminal display scrollback lines
                terminal_line_number = false, -- whether show line number in terminal window
                terminal_signcolumn = false, -- whether show signcolumn in terminal window
                terminal_width = 35,
            },
            inline_messages = 0,
            borders = "single",
        },
    },
    {
        "stevearc/overseer.nvim",
        keys = require("core.utils").generate_lazy_keys("overseer"),
        cmd = { "OverseerRun" },
        opts = {
            templates = { "builtin", "user.cpp_build", "user.run_script" },
            strategy = {
                "toggleterm",
            },
        },
        dependencies = {
            "mfussenegger/nvim-dap",
        },
    },
    {
        "turbio/bracey.vim",
        cmd = { "Bracey", "BraceyReload", "BraceyEval" },
    },
}

local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(pluginlist, lazyconfig)
