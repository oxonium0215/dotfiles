-- Japanese text editing enhancements for LaTeX

local M = {}

-- Setup Japanese input method integration
function M.setup_japanese_input()
    -- Enhanced Japanese text object motions
    vim.api.nvim_set_keymap('n', 'w', '<Plug>(japanese-word-motion-w)', { noremap = false })
    vim.api.nvim_set_keymap('n', 'b', '<Plug>(japanese-word-motion-b)', { noremap = false })
    vim.api.nvim_set_keymap('n', 'e', '<Plug>(japanese-word-motion-e)', { noremap = false })
    
    -- Japanese-aware text formatting
    vim.api.nvim_create_user_command('JapaneseFormat', function()
        local line = vim.fn.getline('.')
        -- Add spaces around English words in Japanese text
        line = line:gsub('([ぁ-んァ-ヴー一-龯])([a-zA-Z])', '%1 %2')
        line = line:gsub('([a-zA-Z])([ぁ-んァ-ヴー一-龯])', '%1 %2')
        vim.fn.setline('.', line)
    end, {})
end

-- LaTeX-specific Japanese snippets
function M.setup_japanese_snippets()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    
    ls.add_snippets("tex", {
        s("ruby", {
            t("\\ruby{"), i(1, "漢字"), t("}{"), i(2, "ふりがな"), t("}")
        }),
        s("japanese", {
            t({
                "\\documentclass[12pt,a4paper]{article}",
                "\\usepackage{luatexja}",
                "\\usepackage[ipaex]{luatexja-preset}",
                "\\setmainjfont{IPAexMincho}",
                "\\setsansjfont{IPAexGothic}",
                "\\begin{document}",
                ""
            }),
            i(1, "内容"),
            t({
                "",
                "\\end{document}"
            })
        })
    })
end

return M
