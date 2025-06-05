-- VimTeX configuration
-- LaTeX editing with compilation, viewing, and navigation support

-- Set PDF viewer based on OS
if vim.fn.has("mac") == 1 then
    vim.g.vimtex_view_method = "skim"
elseif vim.fn.has("unix") == 1 then
    -- Check if we're in WSL
    local is_wsl = vim.fn.system("uname -r"):match("microsoft")
    if is_wsl then
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = "SumatraPDF.exe"
        vim.g.vimtex_view_general_options = "-reuse-instance @pdf"
    else
        vim.g.vimtex_view_method = "zathura"
    end
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
