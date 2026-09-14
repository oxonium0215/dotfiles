return {
  lsp = {
    servers = { "vue_ls" },
    formatters = { "prettier" },
    linters = { "eslint_d" },
  },
  indent = {
    shiftwidth = 2,
    tabstop = 2,
    expandtab = true,
  },
  treesitter = { "vue" },
}
