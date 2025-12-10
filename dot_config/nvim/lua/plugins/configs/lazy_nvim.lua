return {
  defaults = { lazy = true },
  install = { colorscheme = { "onedark" } },

  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      -- To cache all modules, set this to `{}`, but that is not recommended.
      disable_events = { "UIEnter", "BufReadPre" },
      ttl = 3600 * 24 * 2, -- keep unused modules for up to 2 days
    },
    reset_packpath = true, -- reset the package path to improve startup time
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "tar",
        "tarPlugin",
        "zip",
        "zipPlugin",
      },
    },
  },
}
