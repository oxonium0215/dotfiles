-- Japanese text editing enhancements for LuaLaTeX

local M = {}

local function segment_positions(line)
    local ok, tinysegmenter = pcall(require, "tinysegmenter")
    if not ok then
        return nil
    end

    local segments = tinysegmenter.segment(line)
    if type(segments) ~= "table" then
        return nil
    end

    local spans, search_from = {}, 1
    for _, segment in ipairs(segments) do
        local token = tostring(segment)
        local s, e = string.find(line, token, search_from, true)
        if not s or not e then
            return nil
        end
        table.insert(spans, { start = s - 1, finish = e })
        search_from = e + 1
    end

    return spans
end

local function jump_segment(kind)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1], cursor[2]
    local line = vim.api.nvim_get_current_line()
    local spans = segment_positions(line)

    if not spans or #spans == 0 then
        vim.cmd("normal! " .. kind)
        return
    end

    local target
    if kind == "w" then
        for i, span in ipairs(spans) do
            if col < span.start then
                target = span.start
                break
            elseif col >= span.start and col < span.finish and spans[i + 1] then
                target = spans[i + 1].start
                break
            end
        end
    elseif kind == "b" then
        for _, span in ipairs(spans) do
            if span.start < col then
                target = span.start
            elseif col <= span.start then
                break
            end
        end
    elseif kind == "e" then
        for _, span in ipairs(spans) do
            if col <= span.finish - 1 then
                target = span.finish - 1
                break
            end
        end
    end

    if target then
        vim.api.nvim_win_set_cursor(0, { row, target })
    else
        vim.cmd("normal! " .. kind)
    end
end

-- Setup Japanese input method integration
function M.setup_japanese_input()
    local opts = { silent = true }
    vim.keymap.set("n", "<Plug>(japanese-word-motion-w)", function()
        jump_segment("w")
    end, opts)
    vim.keymap.set("n", "<Plug>(japanese-word-motion-b)", function()
        jump_segment("b")
    end, opts)
    vim.keymap.set("n", "<Plug>(japanese-word-motion-e)", function()
        jump_segment("e")
    end, opts)

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
    local ls = require("luasnip")
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
