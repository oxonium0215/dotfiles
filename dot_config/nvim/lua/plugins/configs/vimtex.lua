-- VimTeX configuration optimized for uplatex with Japanese support

-- Set PDF viewer based on OS
if vim.fn.has("mac") == 1 then
    vim.g.vimtex_view_method = "skim"
elseif vim.fn.has("unix") == 1 then
    -- Check if we're in WSL
    local is_wsl = vim.fn.system("uname -r"):match("microsoft")
    if is_wsl then
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = "SumatraPDF.exe"
        vim.g.vimtex_view_general_options = "-reuse-instance -inverse-search \"nvim --headless -c \\\"VimtexInverseSearch %l '%f'\\\"\" @pdf"
    else
        vim.g.vimtex_view_method = "zathura"
    end
else
    vim.g.vimtex_view_method = "general"
end

-- Enhanced mainfile detection for single-file projects
-- Remove the default main file setting to let VimTeX auto-detect
vim.g.vimtex_root_markers = {
    '.latexmkrc',
    -- Remove '.git' to prevent looking up to repository root
    'main.tex',
    'document.tex'
}

-- Compiler settings optimized for uplatex Japanese documents
vim.g.vimtex_compiler_method = "latexmk"

-- Function to check if mylatexformat exists
local function has_myformat()
    local home = os.getenv("HOME")
    local fmt_file = home .. "/myformat.fmt"
    local file = io.open(fmt_file, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- Configure latexmk with conditional mylatexformat support
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
        "-pdfdvi",
        "-shell-escape",
    },
}

-- Enhanced error handling for Japanese documents
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_quickfix_open_on_warning = 0
vim.g.vimtex_quickfix_ignore_filters = {
    'Underfull \\hbox',
    'Overfull \\hbox',
    'Package hyperref Warning',
    'Package otf Warning',
    'LaTeX Font Warning',
}

-- Completion settings
vim.g.vimtex_complete_enabled = 1
vim.g.vimtex_complete_close_braces = 1
vim.g.vimtex_complete_ignore_case = 1
vim.g.vimtex_complete_smart_case = 1

-- Enhanced syntax settings for Japanese
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

-- Japanese-specific syntax groups
vim.g.vimtex_syntax_custom_cmds = {
    {
        name = 'ruby',
        mathmode = 0,
        argspell = 1,
        argstyle = 'bold',
    },
}

-- Disable subfiles support for single-file projects
vim.g.vimtex_subfile_start_local = 0
vim.g.vimtex_include_search_enabled = 0

-- Custom commands for VimTeX
vim.api.nvim_create_user_command('VimtexCreateFormat', function()
    local home = os.getenv("HOME")
    local cmd = string.format("cd %s && uplatex -ini -jobname='myformat' '&uplatex myformat.tex\\dump'", home)
    vim.fn.system(cmd)
    print("mylatexformat created successfully!")
end, { desc = "Create mylatexformat file" })

vim.api.nvim_create_user_command('VimtexCleanAll', function()
    vim.cmd('VimtexClean')
    local fmt_files = vim.fn.glob("*.fmt")
    if fmt_files ~= "" then
        vim.fn.system("rm -f *.fmt")
    end
end, { desc = "Clean all LaTeX auxiliary files including format files" })

-- Set main file manually command
vim.api.nvim_create_user_command('VimtexSetMain', function(opts)
    local main_file = opts.args
    if main_file == "" then
        main_file = vim.fn.input("Main file: ", vim.fn.expand("%:t"))
    end
    vim.b.vimtex_main = main_file
    print("Main file set to: " .. main_file)
    vim.cmd('VimtexReload')
end, {
    nargs = '?',
    desc = "Manually set the main LaTeX file",
    complete = function()
        return vim.fn.glob("*.tex", false, true)
    end
})

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

        -- Auto-detect main file for single-file projects
        local current_file = vim.fn.expand("%:t")  -- Use filename only, not full path

        -- Check if current file contains \documentclass or \begin{document}
        local lines = vim.fn.readfile(vim.fn.expand("%:p"))
        local has_documentclass = false
        local has_begin_document = false

        for _, line in ipairs(lines) do
            if line:match("\\documentclass") then
                has_documentclass = true
                break  -- Early exit for efficiency
            end
            if line:match("\\begin{document}") then
                has_begin_document = true
                break  -- Early exit for efficiency
            end
        end

        -- If current file looks like a main file, set it as such
        if has_documentclass or has_begin_document then
            vim.b.vimtex_main = current_file  -- Use filename only
            print("VimTeX: Main file set to " .. current_file)
        end

        -- Custom key mappings for enhanced workflow
        local opts = { buffer = true, silent = true }

        -- Quick compile with format check
        vim.keymap.set('n', '<localleader>lf', function()
            if has_myformat() then
                print("Compiling with mylatexformat...")
            else
                print("Compiling without mylatexformat (run :VimtexCreateFormat to create)")
            end
            vim.cmd('VimtexCompile')
        end, vim.tbl_extend('force', opts, { desc = "Compile with format awareness" }))

        -- Quick format creation
        vim.keymap.set('n', '<localleader>lF', '<cmd>VimtexCreateFormat<cr>',
            vim.tbl_extend('force', opts, { desc = "Create mylatexformat" }))

        -- Enhanced clean
        vim.keymap.set('n', '<localleader>lC', '<cmd>VimtexCleanAll<cr>',
            vim.tbl_extend('force', opts, { desc = "Clean all auxiliary files" }))

        -- Set main file manually
        vim.keymap.set('n', '<localleader>lm', '<cmd>VimtexSetMain<cr>',
            vim.tbl_extend('force', opts, { desc = "Set main file manually" }))

        -- Reload VimTeX
        vim.keymap.set('n', '<localleader>lr', '<cmd>VimtexReload<cr>',
            vim.tbl_extend('force', opts, { desc = "Reload VimTeX" }))
    end,
})
