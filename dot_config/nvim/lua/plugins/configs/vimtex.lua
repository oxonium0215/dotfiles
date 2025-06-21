-- Enhanced mainfile detection for single-file projects
vim.g.vimtex_root_markers = {
    '.latexmkrc',
    'main.tex',
    'document.tex'
}

-- Force main.tex detection
vim.g.vimtex_main_auto = 1  -- Enable automatic main file detection

-- Japanese-specific autocmds
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
        -- Better Japanese text handling
        vim.opt_local.encoding = "utf-8"
        vim.opt_local.fileencoding = "utf-8"

        -- Enhanced concealment for Japanese LaTeX
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nc"

        -- Better line wrapping for Japanese text
        vim.opt_local.linebreak = true
        vim.opt_local.wrap = true
        vim.opt_local.textwidth = 0
        vim.opt_local.wrapmargin = 0

        -- Enhanced formatting for Japanese
        vim.opt_local.formatoptions = "tcqmMj"

        -- Spell checking (disable for Japanese)
        vim.opt_local.spell = false

        -- UNCONDITIONAL main.tex detection
        local main_candidates = { "main.tex", "document.tex", "thesis.tex", "report.tex" }

        for _, candidate in ipairs(main_candidates) do
            if vim.fn.filereadable(candidate) == 1 then
                vim.b.vimtex_main = candidate
                print("VimTeX: Main file automatically set to " .. candidate)
                break
            end
        end

        -- Fallback: If current file looks like a main file, set it as such
        if not vim.b.vimtex_main then
            local current_file = vim.fn.expand("%:t")
            local lines = vim.fn.readfile(vim.fn.expand("%:p"))
            local has_documentclass = false
            local has_begin_document = false

            for _, line in ipairs(lines) do
                if line:match("\\documentclass") then
                    has_documentclass = true
                    break
                end
                if line:match("\\begin{document}") then
                    has_begin_document = true
                    break
                end
            end

            if has_documentclass or has_begin_document then
                vim.b.vimtex_main = current_file
                print("VimTeX: Main file set to " .. current_file .. " (detected from content)")
            end
        end

        -- Custom key mappings for enhanced workflow
        local opts = { buffer = true, silent = true }

        -- Set main file manually
        vim.keymap.set('n', '<localleader>lm', '<cmd>VimtexSetMain<cr>',
            vim.tbl_extend('force', opts, { desc = "Set main file manually" }))

        -- Reload VimTeX
        vim.keymap.set('n', '<localleader>lr', '<cmd>VimtexReload<cr>',
            vim.tbl_extend('force', opts, { desc = "Reload VimTeX" }))
    end,
})
