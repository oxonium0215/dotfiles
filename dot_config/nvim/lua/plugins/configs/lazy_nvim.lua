return {
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },

  ui = {
    icons = {
--      ft = "・ｶ",
--      lazy = "あ ",
--      loaded = "・・,
--      not_loaded = "・・,
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
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
