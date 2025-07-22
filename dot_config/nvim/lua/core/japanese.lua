-- Japanese text editing enhancements for LuaLaTeX

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

-- LuaLaTeX-specific Japanese snippets
function M.setup_japanese_snippets()
    local ok, ls = pcall(require, "luasnip")
    if not ok then
        return
    end
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    ls.add_snippets("tex", {
        s("ruby", {
            t("\\ruby{"), i(1, "漢字"), t("}{"), i(2, "ふりがな"), t("}")
        }),
        s("lualatex-japanese", {
            t({
                "\\documentclass[12pt,a4paper]{ltjsarticle}",
                "\\usepackage{luatexja}",
                "\\usepackage[hiragino-pron]{luatexja-preset}",
                "\\usepackage{luatexja-ruby}",
                "\\usepackage{fontspec}",
                "",
                "% Japanese font settings",
                "\\setmainjfont{Hiragino Mincho ProN}",
                "\\setsansjfont{Hiragino Sans}",
                "",
                "% Math font",
                "\\usepackage{unicode-math}",
                "\\setmathfont{Latin Modern Math}",
                "",
                "\\begin{document}",
                ""
            }),
            i(1, "内容"),
            t({
                "",
                "\\end{document}"
            })
        }),
        s("lualatex-minimal", {
            t({
                "\\documentclass{ltjsarticle}",
                "\\usepackage{luatexja}",
                "\\begin{document}",
                ""
            }),
            i(1, "内容"),
            t({
                "",
                "\\end{document}"
            })
        }),
        s("textmc", {
            t("\\textmc{"), i(1, "明朝"), t("}")
        }),
        s("textgt", {
            t("\\textgt{"), i(1, "ゴシック"), t("}")
        }),
        s("luacode", {
            t({
                "\\begin{luacode}",
                ""
            }),
            i(1, "-- Lua code here"),
            t({
                "",
                "\\end{luacode}"
            })
        })
    })
end

-- LuaLaTeX specific font switching functions
function M.setup_font_commands()
    vim.api.nvim_create_user_command('SetJapaneseFont', function(opts)
        local font = opts.args
        if font == "" then
            font = vim.fn.input("Font name: ", "Hiragino Mincho ProN")
        end
        local line = string.format("\\setmainjfont{%s}", font)
        vim.fn.append(vim.fn.line('.'), line)
    end, {
    nargs = '?',
    desc = "Set Japanese main font"
})
end

return M
