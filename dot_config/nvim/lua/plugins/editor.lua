local utils = require("core.utils")

return {
  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Motion / Navigation                                                        │
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
  -- │ ∘ Treesitter & Syntax                                                        │
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

  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Code Runner / Task Runner / Live Server                                    │
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
      templates = { "builtin", "user.cpp_build", "user.script_runner" },
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
