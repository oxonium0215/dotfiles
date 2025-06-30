-- Centralize compilation control within vimtex
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_continuous = 1

-- Inform vimtex about the output directories to ensure it can find the PDF and logs
vim.g.vimtex_compiler_latexmk = {
    out_dir = 'out',
    aux_dir = 'aux',
}

vim.g.vimtex_syntax_conceal_disable = 1 -- Disable syntax concealment for better visibility

-- Configure the PDF viewer. Vimtex automatically detects viewers and supports inverse search.
vim.g.vimtex_view_method = 'general' -- Allows vimtex to auto-detect the best viewer
if vim.fn.has('mac') == 1 then
  vim.g.vimtex_view_general_viewer = 'skim'
elseif vim.fn.has('win32') == 1 then
  vim.g.vimtex_view_general_viewer = 'SumatraPDF.exe'
elseif vim.fn.has('wsl') == 1 then
  vim.g.vimtex_view_general_viewer = 'SumatraPDF.exe'
else
  -- You can set your preferred Linux viewer here, e.g., 'zathura', 'okular', 'evince'
  vim.g.vimtex_view_general_viewer = 'zathura'
end

-- Use vimtex's built-in mechanism to find the main project file
vim.g.vimtex_root_markers = {
    '.latexmkrc',
    'main.tex',
    'document.tex',
    'thesis.tex',
    'report.tex'
}
vim.g.vimtex_main_auto = 1

-- Japanese-specific autocmds
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
        -- Settings for Japanese text handling
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
