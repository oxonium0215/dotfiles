local utils = require("core.utils")

return {
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
  -- │ ∘ Keybindings / Clipboard / Sessions / Utilities                             │
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
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      disable_mouse = false,
      disabled_filetypes = { "qf", "alpha", "NvimTree", "lazy", "mason", "oil", "toggleterm" },
      max_count = 10,
    },
  },
  {
    "sirasagi62/tinysegmenter.nvim",
    event = "VeryLazy",
  },
  {
    "nmac427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Core shared libraries (lazy by default)
  { "nvim-lua/plenary.nvim", lazy = true },
  { "kkharji/sqlite.lua", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
}
