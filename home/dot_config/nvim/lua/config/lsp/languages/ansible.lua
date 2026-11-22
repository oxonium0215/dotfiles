return {
  lsp = {
    servers = { "ansiblels" },
    formatters = { "yamlfmt" },
    linters = { "ansible-lint" },
  },
  indent = {
    shiftwidth = 2,
    tabstop = 2,
    expandtab = true,
  },
  treesitter = { "yaml" },
}
