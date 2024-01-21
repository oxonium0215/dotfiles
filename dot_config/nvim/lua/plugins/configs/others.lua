local M = {}
local utils = require "core.utils"

M.blankline = {
    indentLine_enabled = 1,
    filetype_exclude = {
        "help",
        "toggleterm",
        "lazy",
        "NvimTree",
        "lspinfo",
        "TelescopePrompt",
        "TelescopeResults",
        "mason",
        "alpha",
        ""
    },
    context_patterns = {
        "body",
        "class",
        "function",
        "method",
        "block",
        "list_literal",
        "selector",
        "^if",
        "^table",
        "if_statement",
        "while",
        "for",
        "type",
        "var",
        "import",
        "declaration",
        "expression",
        "pattern",
        "primary_expression",
        "statement",
        "switch_body"
    },
    buftype_exclude = {"toggleterm"},
    char = "▎",
    space_char_blankline = " ",
    show_trailing_blankline_indent = false,
    show_first_indent_level = false,
    show_current_context = true,
    show_current_context_start = true
}

M.luasnip = function(opts)
    require("luasnip").config.set_config(opts)

    -- vscode format
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load {paths = vim.g.vscode_snippets_path or ""}

    -- snipmate format
    require("luasnip.loaders.from_snipmate").load()
    require("luasnip.loaders.from_snipmate").lazy_load {paths = vim.g.snipmate_snippets_path or ""}

    -- lua format
    require("luasnip.loaders.from_lua").load()
    require("luasnip.loaders.from_lua").lazy_load {paths = vim.g.lua_snippets_path or ""}

    vim.api.nvim_create_autocmd(
        "InsertLeave",
        {
            callback = function()
                if
                    require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()] and
                        not require("luasnip").session.jump_active
                 then
                    require("luasnip").unlink_current()
                end
            end
        }
    )
end

M.gitsigns = {
    signs = {
        add = {text = "━E"},
        change = {text = "━E"},
        delete = {text = "󰍵"},
        topdelete = {text = "‾"},
        changedelete = {text = "~"},
        untracked = {text = "━E"}
    },
    on_attach = function(bufnr)
        utils.load_mappings("gitsigns", {buffer = bufnr})
    end
}

return M
