local utils = require("core.utils")

return {
  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Dashboard / UI Enhancement                                                 │
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
}
