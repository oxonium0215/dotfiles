local lazyconfig = require("plugins.configs.lazy_nvim")

require("lazy").setup({
  { import = "plugins.core" },
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.lsp" },
  { import = "plugins.git" },
  { import = "plugins.fuzzy" },
  { import = "plugins.lang" },
}, lazyconfig)
