if vim.fn.executable("typst") ~= 1 then
  return {}
end

return {
  treesitter = { "typst" },
  lsp = {
    servers = { "tinymist" },
    setup = {
      tinymist = function()
        return {
          settings = {
            exportPdf = "onType",
          },
        }
      end,
    },
  },
}
