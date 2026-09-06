local utils = require("core.utils")

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = utils.generate_lazy_keys("telescope"),
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "-L",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_sorter = function(...)
          return require("telescope.sorters").get_fuzzy_file(...)
        end,
        file_ignore_patterns = { "node_modules" },
        generic_sorter = function(...)
          return require("telescope.sorters").get_generic_fuzzy_sorter(...)
        end,
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        set_env = { ["COLORTERM"] = "truecolor" },
        mappings = {
          n = { ["q"] = function(...) return require("telescope.actions").close(...) end },
        },
      },
      extensions_list = { "kensaku", "gh", "ui-select", "changes", "live_grep_args", "smart_history", "undo" },
    },
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
}
