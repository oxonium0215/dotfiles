return {
  lsp = {
    servers = { "gopls" },
    formatters = { "gofumpt" },
    requirements = {
      gopls = "go",
      gofumpt = "go",
    },
  },
  indent = {
    shiftwidth = 4,
    tabstop = 4,
    expandtab = false,
  },
  treesitter = { "go" },
}
