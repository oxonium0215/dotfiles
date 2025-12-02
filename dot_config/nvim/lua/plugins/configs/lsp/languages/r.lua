return {
  lsp = {
    servers = { "r_language_server" },
    requirements = {
      ["r_language_server"] = "R",
      ["r-languageserver"] = "R",
    },
    -- formatters intentionally empty; mason does not ship styler
  },
  treesitter = { "r" }
}
