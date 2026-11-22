return {
  lsp = {
    servers = { "omnisharp" },
    formatters = { "csharpier" },
    requirements = {
      csharpier = "dotnet",
    },
  },
  indent = {
    shiftwidth = 4,
    tabstop = 4,
    expandtab = true,
  },
  treesitter = { "c_sharp" },
}
