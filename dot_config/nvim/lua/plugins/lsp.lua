local utils = require("core.utils")

return {
  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Completion & Snippets                                                      │
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
  -- │ ∘ AI Assistance                                                              │
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
  -- │ ∘ LSP / Diagnostics / Tooling                                                │
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

  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Debug Adapter Protocol (DAP)                                               │
  -- ╰──────────────────────────────────────────────────────────────────────────────╯
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
}
