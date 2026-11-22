return {
  lsp = {
    servers = { "bashls" },
    formatters = { "shfmt" },
    linters = { "shellcheck" },
  },
  indent = {
    shiftwidth = 4,
    tabstop = 4,
    expandtab = true,
  },
  treesitter = { "bash" },
}
