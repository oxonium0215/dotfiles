local lazyopts = {
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
      disable_events = { "UIEnter", "BufReadPre" },
      ttl = 3600 * 24 * 2,
    },
    reset_packpath = true,
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

require("lazy").setup({
  { import = "plugins" },
}, lazyopts)
