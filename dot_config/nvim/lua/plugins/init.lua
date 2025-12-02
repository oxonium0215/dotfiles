local utils = require("core.utils")
local uv = vim.uv or vim.loop

local pluginlist = {
    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Profiling / Meta                                                           │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        config = function()
            vim.g.startuptime_tries = 100
        end,
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Clipboard / Misc                                                           │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
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
        keys = utils.generate_lazy_keys("nvimwindow"),
    },
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        opts = {},
    },
    {
        "m4xshen/hardtime.nvim",
        event = { "BufReadPost", "BufAdd", "BufNewFile" },
        dependencies = { "MunifTanjim/nui.nvim" }, -- removed plenary
        opts = {
            disable_mouse = false,
            disabled_filetypes = { "qf", "alpha", "NvimTree", "lazy", "mason", "oil", "toggleterm" },
            max_count = 10,
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "markdown.mdx", "Avante", "codecompanion" },
    },
    {
        "sirasagi62/tinysegmenter.nvim",
        lazy = false,
    },

    -- Core shared libraries (lazy by default)
    { "nvim-lua/plenary.nvim", lazy = true },
    { "kkharji/sqlite.lua", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Indentation                                                                │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "nmac427/guess-indent.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ LaTeX                                                                      │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "lervag/vimtex",
        ft = { "tex", "bib" },
        keys = utils.generate_lazy_keys("vimtex"),
        config = function()
            require("plugins.configs.vimtex")
        end,
    },
    {
        "micangl/cmp-vimtex",
        ft = "tex",
        dependencies = { "hrsh7th/nvim-cmp", "lervag/vimtex" },
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ UI / Theming                                                               │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        cond = function()
            -- Only load alpha if no files are opened
            return vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1
        end,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("plugins.configs.alpha")
        end,
    },
    {
        "VonHeikemen/searchbox.nvim",
        keys = utils.generate_lazy_keys("searchbox"),
        cmd = { "SearchBoxIncSearch", "SearchBoxReplace" },
        dependencies = { "MunifTanjim/nui.nvim" },
    },
    {
        "rcarriga/nvim-notify",
        keys = utils.generate_lazy_keys("notify"),
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
            -- real module is loaded on first notify call
            local orig
            vim.notify = function(...)
                local notify = require("notify")
                if not orig then
                    orig = notify
                end
                vim.notify = orig
                return notify(...)
            end
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
    {
        "nvim-tree/nvim-web-devicons",
        enabled = function()
            return not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false"
        end,
    },
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "darker",
            lualine = {},
        },
    },
    {
        "akinsho/bufferline.nvim",
        event = { "BufReadPost" },
        keys = utils.generate_lazy_keys("bufferline"),
        opts = function()
            return require("plugins.configs.bufferline")
        end,
        config = function(_, opts)
            require("bufferline").setup(opts)
            local function refresh_bufferline()
                local ok, bufferline = pcall(require, "bufferline")
                if ok then
                    bufferline.setup(opts)
                end
            end
            -- session restore fix
            vim.api.nvim_create_autocmd("BufAdd", {
                callback = function()
                    vim.schedule(function()
                        refresh_bufferline()
                    end)
                end,
            })
        end,
    },
    {
        "famiu/bufdelete.nvim",
        cmd = { "Bdelete", "Bwipeout" },
    },
    {
        "Bekaboo/dropbar.nvim",
        event = { "BufReadPost", "BufNewFile" },
        keys = utils.generate_lazy_keys("dropbar"),
    },
    {
        "SmiteshP/nvim-navic",
    },
    {
        "nvim-lualine/lualine.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("plugins.configs.lualine")
        end,
    },
    {
        "stevearc/aerial.nvim",
        keys = utils.generate_lazy_keys("aerial"),
        opts = {},
    },
    {
        "brenoprata10/nvim-highlight-colors",
        -- Removed ft restriction per request (now global)
        event = "BufReadPost",
        opts = {
            render = "background",
            virtual_symbol = "",
            enable_tailwind = true,
        },
    },
    {
        "shellRaining/hlchunk.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = function()
            return require("plugins.configs.hlchunk")
        end,
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Motion                                                                     │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "rlane/pounce.nvim",
        keys = utils.generate_lazy_keys("pounce"),
        cmd = { "Pounce", "PounceRepeat" },
    },
    {
        "smoka7/hop.nvim",
        keys = utils.generate_lazy_keys("hop"),
        opts = {},
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Treesitter                                                                 │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "TSInstall", "TSUpdate", "TSInstallSync", "TSUpdateSync", "TSUninstall", "TSModuleInfo" },
        build = ":TSUpdate",
        config = function()
            require("plugins.configs.treesitter").setup()
        end,
        dependencies = {
            { "JoosepAlviste/nvim-ts-context-commentstring", event = "VeryLazy" },
            {
                "nvim-treesitter/nvim-treesitter-refactor",
                enabled = false, -- incompatible with Treesitter main rewrite
            },
            {
                "nvim-treesitter/nvim-tree-docs",
                enabled = false, -- incompatible with Treesitter main rewrite
            },
            {
                "yioneko/nvim-yati",
                enabled = false, -- incompatible with Treesitter main rewrite
            },
        },
    },
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.configs.rainbow-delimiters")
        end,
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Git                                                                        │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "lewis6991/gitsigns.nvim",
        -- only load gitsigns the first time we detect the current buffer
        -- resides (somewhere up the tree) inside a Git repository.
        init = function()
            local cache = {}
            local function has_git(path)
                if cache[path] ~= nil then
                    return cache[path]
                end
                if path == "" then
                    cache[path] = false
                    return false
                end
                local git_entry = path .. "/.git"
                if uv.fs_stat(git_entry) then
                    cache[path] = true
                    return true
                end
                local parent = vim.fn.fnamemodify(path, ":h")
                if parent == path or parent == "" then
                    cache[path] = false
                    return false
                end
                local res = has_git(parent)
                cache[path] = res
                return res
            end

            vim.api.nvim_create_autocmd("BufReadPre", {
                group = vim.api.nvim_create_augroup("LazyLoadGitsigns", { clear = true }),
                callback = function(args)
                    local file = vim.api.nvim_buf_get_name(args.buf)
                    if file == "" then
                        return
                    end
                    local dir = vim.fn.fnamemodify(file, ":p:h")
                    if has_git(dir) then
                        vim.api.nvim_del_augroup_by_name("LazyLoadGitsigns")
                        require("lazy").load({ plugins = { "gitsigns.nvim" } })
                    end
                end,
            })
        end,
        opts = function()
            return require("plugins.configs.others").gitsigns
        end,
    },
    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = function()
            local cfg = require("plugins.configs.neogit")
            local ok_diff = pcall(require, "diffview")
            local ok_tel = pcall(require, "telescope")
            cfg.integrations = {
                diffview = ok_diff,
                telescope = ok_tel,
            }
            return cfg
        end,
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Completion & Snippets / Autopairs                                          │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        event = "InsertEnter",
        dependencies = { "rafamadriz/friendly-snippets" },
        build = (function()
            if jit and jit.os and jit.os:lower() == "windows" then
                return nil
            end
            return "make install_jsregexp"
        end)(),
        config = function()
            require("plugins.configs.others").luasnip({
                history = true,
                updateevents = "TextChanged,TextChangedI",
            })

            local ok_japanese, japanese = pcall(require, "core.japanese")
            if ok_japanese and japanese.setup_japanese_snippets then
                japanese.setup_japanese_snippets()
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("luasnip-lazy-load", { clear = true }),
                pattern = "*",
                callback = function()
                    require("luasnip.loaders.from_vscode").lazy_load({
                        paths = vim.api.nvim_get_runtime_file("snippets/" .. vim.bo.filetype, true),
                    })
                end,
            })
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            fast_wrap = {},
            disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
            require("nvim-autopairs").setup(opts)
            local ok_cmp, cmp = pcall(require, "cmp")
            if ok_cmp then
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "hrsh7th/cmp-nvim-lsp",
            "saadparwaiz1/cmp_luasnip",
            { "hrsh7th/cmp-buffer", event = "InsertEnter" },
            { "hrsh7th/cmp-path", event = "InsertEnter" },
            { "hrsh7th/cmp-cmdline", event = "CmdlineEnter" },
            "hrsh7th/cmp-calc",
            "lukas-reineke/cmp-rg",
            "petertriho/cmp-git",
            { "lukas-reineke/cmp-under-comparator", event = "VeryLazy" },
            { "onsails/lspkind-nvim", event = "InsertEnter" },
        },
        config = function()
            require("plugins.configs.cmp")
        end,
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ AI Tools                                                                   │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "olimorris/codecompanion.nvim",
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionAction" },
        keys = utils.generate_lazy_keys("codecompanion"),
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

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ LSP / Diagnostics / DAP                                                    │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy", words = { "lazy" } },
            },
        },
    },
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
        dependencies = {
            "neovim/nvim-lspconfig",
            "mason-org/mason.nvim",
            "jay-babu/mason-null-ls.nvim",
            "folke/neoconf.nvim",
        },
        config = function()
            require("plugins.configs.lsp").setup()
        end,
    },
    {
        "jay-babu/mason-null-ls.nvim",
        event = "BufReadPre",
        dependencies = {
            "mason-org/mason.nvim",
            "nvimtools/none-ls.nvim",
        },
        config = function()
            local lsp = require("plugins.configs.lsp")
            require("mason-null-ls").setup({
                -- ensure_installed = lsp.null_ls_ensure, -- Removed for lazy loading
                automatic_installation = false,
                handlers = {},
            })
        end,
    },
    {
        "nvimtools/none-ls.nvim",
        event = "BufReadPre",
        opts = function()
            return require("plugins.configs.null-ls")
        end,
        config = function(_, opts)
            require("null-ls").setup(opts)
        end,
    },
    {
        "folke/trouble.nvim",
        keys = utils.generate_lazy_keys("trouble"),
        cmd = { "Trouble" },
        opts = function()
            return require("plugins.configs.trouble")
        end,
    },
    {
        "mfussenegger/nvim-dap",
        keys = utils.generate_lazy_keys("dap"),
        event = "VeryLazy",
        dependencies = {
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
            },
            "mason-org/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
        },
        config = function()
            require("plugins.configs.dap").setup()
        end,
    },
    {
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = { "CursorHold", "CursorHoldI" },
        opts = {},
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Fuzzy Finder & Telescope Extensions                                        │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        keys = utils.generate_lazy_keys("telescope"),
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = function()
            return require("plugins.configs.telescope")
        end,
        config = function(_, opts)
            require("telescope").setup(opts)
        end,
    },
    {
        "Allianaab2m/telescope-kensaku.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        ft = { "text", "markdown", "gitcommit" },
        config = function()
            pcall(function()
                require("telescope").load_extension("kensaku")
            end)
        end,
    },
    {
        "nvim-telescope/telescope-github.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = "Telescope",
        config = function()
            pcall(function()
                require("telescope").load_extension("gh")
            end)
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        event = "VeryLazy",
        config = function()
            pcall(function()
                require("telescope").load_extension("ui-select")
            end)
        end,
    },
    {
        "LinArcX/telescope-changes.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = "Telescope",
        config = function()
            pcall(function()
                require("telescope").load_extension("changes")
            end)
        end,
    },
    {
        "nvim-telescope/telescope-live-grep-args.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = "Telescope",
        config = function()
            pcall(function()
                require("telescope").load_extension("live_grep_args")
            end)
        end,
    },
    {
        "nvim-telescope/telescope-smart-history.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
        event = "VeryLazy",
        build = function()
            local dir = vim.fs.joinpath(vim.fn.stdpath("state"), "databases")
            os.execute("mkdir -p " .. dir .. "/")
        end,
        config = function()
            pcall(function()
                require("telescope").load_extension("smart_history")
            end)
        end,
    },
    {
        "nvim-telescope/telescope-symbols.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = "Telescope",
    },
    {
        "debugloop/telescope-undo.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = "Telescope",
        config = function()
            pcall(function()
                require("telescope").load_extension("undo")
            end)
        end,
    },

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ File Managers / Terminal                                                   │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-tree/nvim-tree.lua",
        keys = utils.generate_lazy_keys("nvimtree"),
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
        keys = utils.generate_lazy_keys("oil"),
        cmd = { "Oil" },
        opts = require("plugins.configs.oil"),
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },
    {
        "akinsho/toggleterm.nvim",
        keys = utils.generate_lazy_keys("toggleterm"),
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

    -- ╭──────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Code Runner / Tasks / Live Server                                          │
    -- ╰──────────────────────────────────────────────────────────────────────────────╯
    {
        "michaelb/sniprun",
        branch = "master",
        cmd = { "SnipRun" },
        build = "sh install.sh",
        opts = {
            display = { "Terminal", "NvimNotifyErr" },
            display_options = {
                terminal_scrollback = vim.o.scrollback,
                terminal_line_number = false,
                terminal_signcolumn = false,
                terminal_width = 35,
            },
            inline_messages = 0,
            borders = "single",
        },
    },
    {
        "stevearc/overseer.nvim",
        keys = utils.generate_lazy_keys("overseer"),
        cmd = { "OverseerRun" },
        opts = {
            templates = { "builtin", "user.cpp_build", "user.run_script" },
            strategy = { "toggleterm" },
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
