local utils = require("core.utils")
local uv = vim.uv or vim.loop

local pluginlist = {
  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Profiling / Meta                                                           │
  -- ╰──────────────────────────────────────────────────────────────────────────────╯
  {
    "willothy/flatten.nvim",
    lazy = false,
    priority = 1001,
    opts = function()
      return require("plugins.configs.flatten")
    end,
  },
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
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "gbprod/yanky.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ring = { history_length = 100 },
      highlight = { timer = 200 },
    },
    keys = {
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "GPut after cursor" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "GPut before cursor" },
      { "[y", "<Plug>(YankyPreviousEntry)", desc = "Cycle backward through yank history" },
      { "]y", "<Plug>(YankyNextEntry)", desc = "Cycle forward through yank history" },
      { "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Cycle backward through yank history" },
      { "<c-n>", "<Plug>(YankyNextEntry)", desc = "Cycle forward through yank history" },
      { "<leader>fy", "<cmd>Telescope yank_history<CR>", desc = "Telescope yank history" },
    },
    config = function(_, opts)
      require("yanky").setup(opts)
      pcall(function()
        require("telescope").load_extension("yank_history")
      end)
    end,
  },
  -- deferred-clipboard is inlined in core/autocmds.lua
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
    enabled = false,
  },
  {
    "sirasagi62/tinysegmenter.nvim",
    event = "VeryLazy",
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
  -- │ ∘ Typst                                                                      │
  -- ╰──────────────────────────────────────────────────────────────────────────────╯
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    enabled = function()
      return vim.fn.executable("typst") == 1
    end,
    build = function()
      require("typst-preview").update()
    end,
    opts = {},
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
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    keys = utils.generate_lazy_keys("fidget"),
    opts = {
      notification = {
        override_vim_notify = true,
      },
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
    event = { "BufReadPost", "BufNewFile", "TermEnter" },
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
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
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
      { "JoosepAlviste/nvim-ts-context-commentstring", event = "VeryLazy", opts = { enable_autocmd = false } },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("plugins.configs.treesitter-textobjects").setup()
    end,
  },
  {
    "Wansmer/treesj",
    keys = {
      { "<leader>m", "<cmd>TSJToggle<CR>", desc = "Toggle Split/Join (TreeSJ)" },
      { "<leader>j", "<cmd>TSJJoin<CR>", desc = "Join Node (TreeSJ)" },
      { "<leader>s", "<cmd>TSJSplit<CR>", desc = "Split Node (TreeSJ)" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
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
    event = { "BufReadPost", "BufNewFile" },
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
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      enable_builtin = true,
      default_to_projects_v2 = true,
      default_merge_method = "squash",
      picker = "telescope",
    },
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
    "cordx56/rustowl",
    ft = { "rust" },
    keys = utils.generate_lazy_keys("rustowl"),
    -- rustowl binary is managed by mise (cargo:rustowl)
    opts = {
      auto_enable = true,
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
    },
    config = function()
      require("plugins.configs.lsp").setup()
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("plugins.configs.conform").setup()
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.configs.lint").setup()
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
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous todo comment",
      },
      { "<leader>xt", "<cmd>TodoTrouble<CR>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<CR>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Todo (Telescope)" },
    },
  },
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      completion = {
        cmp = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
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
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      require("plugins.configs.dap").setup()
    end,
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
      vim.fn.mkdir(dir, "p")
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
    build = "sh install.sh",
    enabled = function()
      return vim.fn.has("win32") == 0
    end,
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
    cmd = {
      "OverseerRun",
      "OverseerToggle",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerBuild",
      "OverseerClearCache",
    },
    opts = {
      templates = { "builtin", "user.cpp_build", "user.run_script" },
      strategy = { "toggleterm" },
    },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
  {
    "Mythos-404/xmake.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    enabled = function()
      return vim.fn.executable("xmake") == 1
    end,
    event = "VeryLazy",
    keys = utils.generate_lazy_keys("xmake"),
    cmd = {
      "XMakeConfig",
      "XMakeBuild",
      "XMakeRun",
      "XMakeDebug",
      "XMakeStop",
      "XMakeStatus",
      "XMakeLog",
      "XMakeClean",
      "XMakeProject",
      "XMakeMenu",
    },
    config = function()
      require("plugins.configs.xmake")
    end,
  },
  {
    "turbio/bracey.vim",
    cmd = { "Bracey", "BraceyReload", "BraceyEval" },
  },
}

local lazyconfig = require("plugins.configs.lazy_nvim")
require("lazy").setup(pluginlist, lazyconfig)
