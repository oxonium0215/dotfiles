return {
  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Git Integrations                                                           │
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
}
