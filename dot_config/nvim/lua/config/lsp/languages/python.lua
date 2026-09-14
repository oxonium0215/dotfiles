return {
  lsp = {
    servers = { "pyright" },
    formatters = { "ruff_format" },
    linters = { "ruff" },
  },
  indent = {
    shiftwidth = 4,
    tabstop = 4,
    expandtab = true,
  },
  treesitter = { "python" },
}
