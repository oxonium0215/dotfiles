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

require("lazy").setup({
  { import = "plugins" },
}, lazyopts)
