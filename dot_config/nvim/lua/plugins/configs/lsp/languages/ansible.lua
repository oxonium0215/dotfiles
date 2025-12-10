return {
  lsp = {
    servers = { "ansiblels" },
    formatters = { "yamlfmt" },
    linters = { "ansible-lint" },
  },
  treesitter = { "yaml" },
}
