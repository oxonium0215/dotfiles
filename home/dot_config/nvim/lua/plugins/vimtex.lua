local utils = require("core.utils")

return {
  {
    "lervag/vimtex",
    ft = { "tex", "bib" },
    keys = utils.generate_lazy_keys("vimtex"),
    config = function()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_continuous = 1
      vim.g.vimtex_compiler_latexmk = {
        out_dir = "out",
        aux_dir = "aux",
      }
      vim.g.vimtex_syntax_conceal_disable = 1

      vim.g.vimtex_view_method = "general"
      if vim.fn.has("mac") == 1 then
        vim.g.vimtex_view_general_viewer = "skim"
      elseif vim.fn.has("win32") == 1 or vim.fn.has("wsl") == 1 then
        vim.g.vimtex_view_general_viewer = "SumatraPDF.exe"
      else
        vim.g.vimtex_view_general_viewer = "zathura"
      end

      vim.g.vimtex_root_markers = {
        ".latexmkrc",
        "main.tex",
        "document.tex",
        "thesis.tex",
        "report.tex",
      }
      vim.g.vimtex_main_auto = 1

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          vim.opt_local.encoding = "utf-8"
          vim.opt_local.fileencoding = "utf-8"
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = "nc"
          vim.opt_local.linebreak = true
          vim.opt_local.wrap = true
          vim.opt_local.textwidth = 0
          vim.opt_local.wrapmargin = 0
          vim.opt_local.formatoptions = "tcqmMj"
          vim.opt_local.spell = false
        end,
      })
    end,
  },
  {
    "micangl/cmp-vimtex",
    ft = "tex",
    dependencies = { "hrsh7th/nvim-cmp", "lervag/vimtex" },
  },
}
