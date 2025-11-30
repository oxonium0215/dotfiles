return {
  lsp = {
    servers = { "clangd" },
    setup = {
      clangd = function()
        return {
          cmd = { "clangd", "--offset-encoding=utf-16", "--background-index", "--clang-tidy" },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
            semanticHighlighting = true,
          },
        }
      end,
    },
  },
  treesitter = { "c" },
}
