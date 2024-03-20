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
            vim.g.startuptime_tries = 10
        end
    },
    {
        "EtiamNullam/deferred-clipboard.nvim",
        event = "VeryLazy"
    },
    {
        "jedrzejboczar/possession.nvim",
        dependencies = {"nvim-lua/plenary.nvim"},
        cmd = {
            "PossessionSave",
            "PossessionLoad",
            "PossessionRename",
            "PossessionClose",
            "PossessionDelete",
            "PossessionShow",
            "PossessionList",
            "PossessionMigrate"
        }
    },
    {
        "yorickpeterse/nvim-window",
        init = function()
            require("core.utils").load_mappings "nvimwindow"
        end
    },
    {
        "m4xshen/hardtime.nvim",
        event = {"BufReadPost", "BufAdd", "BufNewFile"},
        dependencies = {"MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim"},
        opts = {
            disable_mouse = false,
            disabled_filetypes = {"qf", "alpha", "NvimTree", "lazy", "mason", "oil", "toggleterm"},
            max_count = 10,
        }
    },
    -- Lua Library
    {"nvim-lua/popup.nvim"},
    {"nvim-lua/plenary.nvim"},
    {"kkharji/sqlite.lua"},
    {"MunifTanjim/nui.nvim"},
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ UI                                                                            │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    -- Startup screen
    {
        "goolord/alpha-nvim",
        event = "BufWinEnter",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            require("plugins.configs.alpha")
        end
    },
    -- Search
    {
        "VonHeikemen/searchbox.nvim",
        init = function()
            require("core.utils").load_mappings "searchbox"
        end,
        cmd = {"SearchBoxIncSearch", "SearchBoxReplace"},
        dependencies = {"MunifTanjim/nui.nvim"}
    },
    -- Cmdline
    --[[
    {
        "VonHeikemen/fine-cmdline.nvim",
        init = function()
            require("core.utils").load_mappings "cmdline"
        end,
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
    -- Notify
    {
        "vigoux/notifier.nvim",
        event = "VeryLazy",
        config = function()
            require "notifier".setup {}
        end
    },
    -- Font
    {
        "nvim-tree/nvim-web-devicons",
        enabled = function()
            return not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false"
        end
    },
    -- colorscheme
    {
        {"EdenEast/nightfox.nvim", event = "BufWinEnter"},
        {"navarasu/onedark.nvim", event = "BufWinEnter"},
        {"Mofiqul/vscode.nvim", event = "BufWinEnter"}
    },
    {
        "akinsho/bufferline.nvim",
        event = {"BufReadPost", "BufAdd", "BufNewFile"},
        opts = function()
            return require "plugins.configs.bufferline"
        end,
        config = function(_, opts)
            require("core.utils").load_mappings "bufferline"
            require("bufferline").setup(opts)
            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd(
                "BufAdd",
                {
                    callback = function()
                        vim.schedule(
                            function()
                                pcall(nvim_bufferline)
                            end
                        )
                    end
                }
            )
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        event = {"BufReadPost", "BufAdd", "BufNewFile"},
        dependencies = {},
        config = function()
            require("plugins.configs.lualine")
        end
    },
    {
        "brenoprata10/nvim-highlight-colors"
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        version = "2.20.8",
        event = {"CursorHold", "CursorHoldI"},
        init = function()
            require("core.utils").lazy_load "indent-blankline.nvim"
        end,
        opts = function()
            return require("plugins.configs.others").blankline
        end,
        config = function(_, opts)
            require("core.utils").load_mappings "blankline"
            require("indent_blankline").setup(opts)
        end
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Easymotion                                                                    │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "rlane/pounce.nvim",
        init = function()
            require("core.utils").load_mappings "pounce"
        end,
        cmd = {"Pounce", "PounceRepeat"}
    },
    {
        "phaazon/hop.nvim",
        branch = "v2",
        init = function()
            require("core.utils").load_mappings "hop"
        end,
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require "hop".setup {keys = "etovxqpdygfblzhckisuran"}
        end
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Treesitter                                                                    │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-treesitter/nvim-treesitter",
        init = function()
            require("core.utils").lazy_load "nvim-treesitter"
        end,
        cmd = {"TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo"},
        event = "BufReadPost",
        dependencies = {
            {"JoosepAlviste/nvim-ts-context-commentstring"},
            {"nvim-treesitter/nvim-treesitter-refactor"},
            {"nvim-treesitter/nvim-tree-docs"},
            {"yioneko/nvim-yati"}
        },
        build = ":TSUpdate",
        opts = function()
            return require "plugins.configs.treesitter"
        end,
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end
    },
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufReadPost",
        config = function()
            -- patch https://github.com/nvim-treesitter/nvim-treesitter/issues/1124
            vim.cmd.edit({bang = true})
        end
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Git stuff                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "lewis6991/gitsigns.nvim",
        ft = {"gitcommit", "diff"},
        event = {"CursorHold", "CursorHoldI"},
        init = function()
            -- load gitsigns only when a git file is opened
            vim.api.nvim_create_autocmd(
                {"BufRead"},
                {
                    group = vim.api.nvim_create_augroup("GitSignsLazyLoad", {clear = true}),
                    callback = function()
                        vim.fn.system("git -C " .. '"' .. vim.fn.expand "%:p:h" .. '"' .. " rev-parse")
                        if vim.v.shell_error == 0 then
                            vim.api.nvim_del_augroup_by_name "GitSignsLazyLoad"
                            vim.schedule(
                                function()
                                    require("lazy").load {plugins = {"gitsigns.nvim"}}
                                end
                            )
                        end
                    end
                }
            )
        end,
        opts = function()
            return require("plugins.configs.others").gitsigns
        end,
        config = function(_, opts)
            require("gitsigns").setup(opts)
        end
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
                    updateevents = "TextChanged,TextChangedI"
                },
                config = function(_, opts)
                    require("plugins.configs.others").luasnip(opts)
                end
            },
            {
                -- AI completion
                "zbirenbaum/copilot.lua",
                -- cmd = { "Copilot" },
                event = "InsertEnter",
                config = function()
                    vim.defer_fn(
                        function()
                            require("plugins.configs.copilot")
                        end,
                        100
                    )
                end
            }, -- autopairing of (){}[] etc
            {
                "windwp/nvim-autopairs",
                opts = {
                    fast_wrap = {},
                    disable_filetype = {"TelescopePrompt", "vim"}
                },
                config = function(_, opts)
                    require("nvim-autopairs").setup(opts)

                    -- setup cmp for autopairs
                    local cmp_autopairs = require "nvim-autopairs.completion.cmp"
                    require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
                end
            }, -- cmpソース
            {
                "hrsh7th/cmp-path", -- パス補完用
                "hrsh7th/cmp-buffer", -- バッファ補完用
                "hrsh7th/cmp-nvim-lua", -- Lua補完用
                "saadparwaiz1/cmp_luasnip", -- LuaSnip用
                "hrsh7th/cmp-nvim-lsp", -- lsp補完用
                "hrsh7th/cmp-emoji", -- emoji用
                "hrsh7th/cmp-calc", -- 計算用
                "f3fora/cmp-spell", -- vimのspell機能から補完
                {
                    -- Copilot用
                    "zbirenbaum/copilot-cmp",
                    config = true
                },
                "ray-x/cmp-treesitter", -- Treesitter用
                "lukas-reineke/cmp-rg", -- ripgrep用
                "lukas-reineke/cmp-under-comparator", -- 補完並び替え
                {
                    -- アイコン表示
                    "onsails/lspkind-nvim",
                    config = function()
                        require("plugins.configs.lspkind")
                    end
                }
            }
        },
        opts = function()
            return require "plugins.configs.cmp"
        end,
        config = function(_, opts)
            require("cmp").setup(opts)
        end
    },
    {
        "j-hui/fidget.nvim",
        tag = "legacy",
        event = "LspAttach",
        opts = {}
    },
    {
        "numToStr/Comment.nvim",
        event = {"CursorHold", "CursorHoldI"},
        keys = {
            {"gcc", mode = "n", desc = "Comment toggle current line"},
            {"gc", mode = {"n", "o"}, desc = "Comment toggle linewise"},
            {"gc", mode = "x", desc = "Comment toggle linewise (visual)"},
            {"gbc", mode = "n", desc = "Comment toggle current block"},
            {"gb", mode = {"n", "o"}, desc = "Comment toggle blockwise"},
            {"gb", mode = "x", desc = "Comment toggle blockwise (visual)"}
        },
        init = function()
            require("core.utils").load_mappings "comment"
        end,
        config = function(_, opts)
            require("Comment").setup(opts)
        end
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ LSP & DAP                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "williamboman/mason.nvim",
        cmd = {"Mason", "MasonInstall", "MasonInstallAll", "MasonUninstall", "MasonUninstallAll", "MasonLog"},
        opts = function()
            return require "plugins.configs.mason"
        end,
        config = function(_, opts)
            require("mason").setup(opts)

            -- custom cmd to install all mason binaries listed
            vim.api.nvim_create_user_command(
                "MasonInstallAll",
                function()
                    vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
                end,
                {}
            )

            vim.g.mason_binaries_list = opts.ensure_installed
        end
    },
    {
        "neovim/nvim-lspconfig",
        init = function()
            require("core.utils").lazy_load "nvim-lspconfig"
            vim.lsp.handlers["textDocument/publishDiagnostics"] =
            vim.lsp.with(
                vim.lsp.diagnostic.on_publish_diagnostics,
                {
                    -- delay update diagnostics
                    update_in_insert = true
                }
            )
        end,
        event = {"CursorHold", "CursorHoldI"},
        config = function()
            --    require "plugins.configs.lspconfig"
            --    require "plugins.configs.lsp"
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = "BufReadPre",
        config = function()
            require("plugins.configs.mason-lspconfig")
        end,
        dependencies = {
            {
                "folke/neoconf.nvim",
                config = function()
                    require("plugins.configs.neoconf")
                    require "plugins.configs.lspconfig"
                    require "plugins.configs.lsp"
                end
            },
            {
                "folke/neodev.nvim",
                config = function()
                    require("plugins.configs.neodev")
                end
            },
            {
                "weilbith/nvim-lsp-smag",
                after = "nvim-lspconfig"
            }
        }
    },
    {
        "mfussenegger/nvim-dap",
        keys = {
  { "<F5>", function() require'dap'.continue() end, desc = "Debug: Start/Continue" },
  { "<F1>", function() require'dap'.step_into() end, desc = "Debug: Step Into" },
  { "<F2>", function() require'dap'.step_over() end, desc = "Debug: Step Over" },
  { "<F3>", function() require'dap'.step_out() end, desc = "Debug: Step Out" },
  { "<leader>b", function() require'dap'.toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
  { "<leader>B", function() require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Debug: Set Breakpoint with Condition" }
},

        dependencies = {
            -- Creates a beautiful debugger UI
            {
                "rcarriga/nvim-dap-ui",
                dependencies = {"nvim-neotest/nvim-nio"},
            },
            -- Installs the debug adapters for you
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim"
        },
        config = function()
            require("plugins.configs.dap")
        end
    },
    {
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = {"CursorHold", "CursorHoldI"},
        opts = {}
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Telescope                                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            {
                "nvim-lua/plenary.nvim"
            },
            {
                "Allianaab2m/telescope-kensaku.nvim",
                config = function()
                    require("telescope").load_extension("kensaku") -- :Telescope kensaku
                end
            },
            {
                "nvim-treesitter/nvim-treesitter"
            },
            {
                "nvim-telescope/telescope-github.nvim",
                config = function()
                    require("telescope").load_extension("gh")
                end
            },
            {
                "nvim-telescope/telescope-ui-select.nvim",
                config = function()
                    require("telescope").load_extension("ui-select")
                end
            },
            {
                "LinArcX/telescope-changes.nvim",
                config = function()
                    require("telescope").load_extension("changes")
                end
            },
            {
                "nvim-telescope/telescope-live-grep-args.nvim",
                config = function()
                    require("telescope").load_extension("live_grep_args")
                end
            },
            {
                "nvim-telescope/telescope-smart-history.nvim",
                config = function()
                    require("telescope").load_extension("smart_history")
                end,
                build = function()
                    os.execute("mkdir -p " .. vim.fn.stdpath("state") .. "databases/")
                end
            },
            {
                "nvim-telescope/telescope-symbols.nvim"
            },
            {
                "debugloop/telescope-undo.nvim",
                config = function()
                    require("telescope").load_extension("undo")
                end
            }
        },
        cmd = "Telescope",
        init = function()
            require("core.utils").load_mappings "telescope"
        end,
        opts = function()
            return require "plugins.configs.telescope"
        end,
        config = function(_, opts)
            local telescope = require "telescope"
            telescope.setup(opts)

            -- load extensions
            for _, ext in ipairs(opts.extensions_list) do
                telescope.load_extension(ext)
            end
        end
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Filer & Terminal                                                              │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "nvim-tree/nvim-tree.lua",
        cmd = {
            "NvimTreeToggle",
            "NvimTreeOpen",
            "NvimTreeFindFile",
            "NvimTreeFindFileToggle",
            "NvimTreeRefresh"
        },
        init = function()
            require("core.utils").load_mappings "nvimtree"
        end,
        opts = function()
            return require "plugins.configs.nvim-tree"
        end,
        config = function(_, opts)
            require("nvim-tree").setup(opts)
        end
    },
    {
        "akinsho/toggleterm.nvim",
        init = function()
            require("core.utils").load_mappings "toggleterm"
        end,
        cmd = {
            "ToggleTerm",
            "ToggleTermSetName",
            "ToggleTermToggleAll",
            "ToggleTermSendVisualLines",
            "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualSelection"
        },
        config = require("plugins.configs.toggleterm")
    },
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ ∘ Code Runner & Live server                                                     │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "michaelb/sniprun",
        branch = "master",
        cmd = {"SnipRun"},
        build = "sh install.sh",
        -- do 'sh install.sh 1' if you want to force compile locally
        -- (instead of fetching a binary from the github release). Requires Rust >= 1.65

        config = function()
            require("sniprun").setup(
                {
                    display = {"Terminal", "NvimNotifyErr"},
                    display_options = {
                        terminal_scrollback = vim.o.scrollback, -- change terminal display scrollback lines
                        terminal_line_number = false, -- whether show line number in terminal window
                        terminal_signcolumn = false, -- whether show signcolumn in terminal window
                        terminal_width = 35
                    },
                    inline_messages = 0,
                    borders = "single"
                }
            )
        end
    },
    {
        "stevearc/overseer.nvim",
        init = function()
            require("core.utils").load_mappings "overseer"
        end,
        cmd = {"OverseerRun"},
        config = function()
            require("overseer").setup(
                {
                    templates = {"builtin", "user.cpp_build", "user.run_script"},
                    strategy = {
                        "toggleterm"
                    }
                }
            )
        end,
        dependencies = {
            "mfussenegger/nvim-dap"
        }
    },
    {
        "turbio/bracey.vim",
        cmd = {"Bracey", "BraceyReload", "BraceyEval"}
    }
}

local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(pluginlist, lazyconfig)
