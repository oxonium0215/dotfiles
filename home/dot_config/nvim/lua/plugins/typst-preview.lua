return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  enabled = function()
    return vim.fn.executable("typst") == 1
  end,
  build = function()
    require("typst-preview").update()
  end,
  opts = {},
}
