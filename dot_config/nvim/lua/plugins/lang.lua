local utils = require("core.utils")

return {
  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ LaTeX                                                                      │
  -- ╰──────────────────────────────────────────────────────────────────────────────╯
  {
    "lervag/vimtex",
    ft = { "tex", "bib" },
    keys = utils.generate_lazy_keys("vimtex"),
    config = function()
      require("plugins.configs.vimtex")
    end,
  },
  {
    "micangl/cmp-vimtex",
    ft = "tex",
    dependencies = { "hrsh7th/nvim-cmp", "lervag/vimtex" },
  },

  -- ╭──────────────────────────────────────────────────────────────────────────────╮
  -- │ ∘ Typst                                                                      │
  -- ╰──────────────────────────────────────────────────────────────────────────────╯
  {
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
  },
}
