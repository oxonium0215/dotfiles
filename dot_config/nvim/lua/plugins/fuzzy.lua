local utils = require("core.utils")

return {
  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Fuzzy Finder & Extensions                                                  │
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
  -- │ ∘ File Explorer / Buffer Management                                          │
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

  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Terminal Emulator                                                          │
  -- ╰──────────────────────────────────────────────────────────────────────────────╯
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
}
