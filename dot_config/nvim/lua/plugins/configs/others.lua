local M = {}
local utils = require "core.utils"

M.blankline = function()
    return {
        indent = {
            char = '▏',
        },
        exclude = {
            filetypes = {
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
            buftypes = {"toggleterm"},
        },
        scope = {
            enabled = true,
            highlight = {
                start = true,
            },
            patterns = {
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
            }
        },
        whitespace = {
            remove_blankline_trail = false,
        },
        show_trailing_blankline_indent = false,
        show_first_indent_level = false,
    }
end


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

    local unlink_group = vim.api.nvim_create_augroup("LuasnipUnlinkOnLeave", { clear = true })
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = unlink_group,
        callback = function()
            if
                require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()] and
                not require("luasnip").session.jump_active
            then
                require("luasnip").unlink_current()
            end
        end,
    })
    end

    M.gitsigns = {
        signs = {
            add = {text = ""},
            change = {text = ""},
            delete = {text = ""},
            topdelete = {text = ""},
            changedelete = {text = ""},
            untracked = {text = ""},
        },
        current_line_blame = true,
        on_attach = function(bufnr)
            utils.set_mappings("gitsigns", {buffer = bufnr})
        end
    }

    return M
