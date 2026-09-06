local utils = require("vscode-config.utils")

local pluginlist = {
  -- ╭─────────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Text Editing / Motions                                                        │
  -- ╰─────────────────────────────────────────────────────────────────────────────────╯
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
  {
    "m4xshen/hardtime.nvim",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      disable_mouse = false,
      max_count = 10,
    },
  },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Flash (modern motion in VSCode)
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
    },
  },

  -- Hop
  {
    "smoka7/hop.nvim",
    keys = utils.generate_lazy_keys("hop"),
    opts = {},
  },

  -- TreeSJ (Split / Join)
  {
    "Wansmer/treesj",
    keys = {
      { "<leader>m", "<cmd>TSJToggle<CR>", desc = "Toggle Split/Join (TreeSJ)" },
      { "<leader>j", "<cmd>TSJJoin<CR>", desc = "Join Node (TreeSJ)" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
  },

  -- Yanky
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
    },
    config = function(_, opts)
      require("yanky").setup(opts)
    end,
  },
}

local lazyopts = {
  defaults = { lazy = true },
  performance = {
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      disable_events = { "UIEnter", "BufReadPre" },
      ttl = 3600 * 24 * 2,
    },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "tar",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zip",
        "zipPlugin",
        "rplugin",
        "spellfile",
      },
    },
  },
}

require("lazy").setup(pluginlist, lazyopts)
