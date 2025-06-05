-- VimTeX configuration
-- LaTeX editing with compilation, viewing, and navigation support

-- Set PDF viewer based on OS. Use SmatraPDF for WSL.
if vim.fn.has("mac") == 1 then
    vim.g.vimtex_view_method = "skim"
elseif vim.fn.has("unix") == 1 then
    vim.g.vimtex_view_method = "zathura"
else
    vim.g.vimtex_view_method = "general"
end

-- Compiler settings
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_latexmk = {
    aux_dir = "aux",
    out_dir = "out",
    callback = 1,
    continuous = 1,
    executable = "latexmk",
    hooks = {},
    options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
    },
}

-- Quickfix settings
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_quickfix_open_on_warning = 0

-- Fold settings
vim.g.vimtex_fold_enabled = 0
vim.g.vimtex_fold_types = {
    cmd_addplot = {
        cmds = { "addplot", "addplot3", "addplot+", "addplot3+" },
    },
    cmd_multi = {
        cmds = {
            "%(begin|end)",
            "%(chapter|section|subsection|subsubsection)",
        },
    },
    comments = {
        enabled = 1,
    },
    env_options = vim.empty_dict(),
    envs = {
        blacklist = {},
        whitelist = { "figure", "table", "equation", "align" },
    },
    items = {
        enabled = 1,
        opened = 0,
    },
    markers = vim.empty_dict(),
    preamble = {
        enabled = 1,
    },
    sections = {
        parse_levels = 1,
        parts = { "appendix", "frontmatter", "mainmatter", "backmatter" },
        sections = {
            "%(add)?part",
            "%(chapter|addchap)",
            "%(section|addsec)",
            "%(subsection|addsubsec)",
            "subsubsection",
            "paragraph",
            "subparagraph",
        },
    },
}

-- Syntax settings
vim.g.vimtex_syntax_enabled = 1
vim.g.vimtex_syntax_conceal = {
    accents = 1,
    cites = 1,
    fancy = 1,
    greek = 1,
    math_bounds = 1,
    math_delimiters = 1,
    math_fracs = 1,
    math_super_sub = 1,
    math_symbols = 1,
    sections = 0,
    styles = 1,
}

-- Table of contents settings
vim.g.vimtex_toc_config = {
    name = "Table of Contents",
    layers = { "content", "todo", "include" },
    split_width = 40,
    todo_sorted = 0,
    show_help = 1,
    show_numbers = 1,
}

-- Completion settings
vim.g.vimtex_complete_enabled = 1
vim.g.vimtex_complete_close_braces = 1

-- Indentation settings
vim.g.vimtex_indent_enabled = 1
vim.g.vimtex_indent_bib_enabled = 1

-- Import settings
vim.g.vimtex_subfile_start_local = 1
vim.g.vimtex_include_search_enabled = 1

-- Disable mappings that conflict with our custom ones
vim.g.vimtex_mappings_enabled = 0

-- Enable LaTeX-specific features for .tex files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
        -- Enable spell checking for LaTeX files
        -- vim.opt_local.spell = true
        -- vim.opt_local.spelllang = { "en_us", "ja" }

        -- Set better text width for LaTeX
        vim.opt_local.textwidth = 80
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true

        -- Better concealment for LaTeX
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nc"

        -- Auto-formatting options
        vim.opt_local.formatoptions:append("t") -- Auto-wrap text using textwidth
        vim.opt_local.formatoptions:append("c") -- Auto-wrap comments using textwidth
        vim.opt_local.formatoptions:append("q") -- Allow formatting of comments with "gq"
        vim.opt_local.formatoptions:remove("o") -- Don't continue comments when pressing o/O
    end,
})

-- Setup completion source for vimtex
local ok, cmp = pcall(require, "cmp")
if ok then
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
            cmp.setup.buffer({
                sources = cmp.config.sources({
                    { name = "vimtex" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.menu = ({
                            vimtex = "[VimTeX]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
            })
        end,
    })
end
