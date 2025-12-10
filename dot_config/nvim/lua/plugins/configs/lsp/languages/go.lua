return {
  lsp = {
    servers = { "gopls" },
    formatters = { "gofumpt" },
    requirements = {
      gopls = "go",
      gofumpt = "go",
    },
  },
  treesitter = { "go" },
}
