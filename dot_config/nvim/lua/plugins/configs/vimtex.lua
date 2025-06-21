-- Enhanced mainfile detection for single-file projects
vim.g.vimtex_root_markers = {
    '.latexmkrc',
    'main.tex',
    'document.tex',
    'thesis.tex',
    'report.tex'
}

-- Enable automatic main file detection
vim.g.vimtex_main_auto = 1

-- Function to find main file recursively
local function find_main_file(start_dir)
    local main_candidates = { "main.tex", "document.tex", "thesis.tex", "report.tex" }
    local current_dir = start_dir or vim.fn.getcwd()
    local max_depth = 3  -- Prevent infinite recursion

    local function search_directory(dir, depth)
        if depth > max_depth then return nil end

        -- Check for main file candidates in current directory
        for _, candidate in ipairs(main_candidates) do
            local full_path = dir .. "/" .. candidate
            if vim.fn.filereadable(full_path) == 1 then
                return full_path
            end
        end

        -- Check parent directory
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent ~= dir then  -- Not at filesystem root
            return search_directory(parent, depth + 1)
        end

        return nil
    end

    return search_directory(current_dir, 0)
end

-- Function to detect main file from content
local function is_main_file(filepath)
    local file = io.open(filepath, "r")
    if not file then return false end

    local content = file:read("*a")
    file:close()

    return content:match("\\documentclass") or content:match("\\begin{document}")
end

-- Japanese-specific autocmds with enhanced main file detection
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
        -- Better Japanese text handling
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

        -- ENHANCED main file detection
        local current_file = vim.fn.expand("%:p")
        local current_dir = vim.fn.expand("%:p:h")
        local current_filename = vim.fn.expand("%:t")

        -- Strategy 1: Look for main file in current and parent directories
        local main_file_path = find_main_file(current_dir)

        if main_file_path then
            local main_filename = vim.fn.fnamemodify(main_file_path, ":t")
            vim.b.vimtex_main = main_filename
            print("VimTeX: Main file automatically detected: " .. main_filename)

            -- Set working directory to main file's directory if different
            local main_dir = vim.fn.fnamemodify(main_file_path, ":h")
            if main_dir ~= current_dir then
                vim.cmd("cd " .. main_dir)
                print("VimTeX: Changed working directory to: " .. main_dir)
            end
        else
            -- Strategy 2: Check if current file is a main file
            if is_main_file(current_file) then
                vim.b.vimtex_main = current_filename
                print("VimTeX: Main file set to current file: " .. current_filename)
            else
                -- Strategy 3: Manual intervention required
                print("VimTeX: No main file detected. Use <localleader>lm to set manually.")
                print("VimTeX: Searched in: " .. current_dir .. " and parent directories")
            end
        end

        -- Custom key mappings for enhanced workflow
        local opts = { buffer = true, silent = true }

        -- Set main file manually with completion
        vim.keymap.set('n', '<localleader>lm', function()
            local tex_files = vim.fn.glob("**/*.tex", false, true)
            if #tex_files > 0 then
                vim.ui.select(tex_files, {
                    prompt = "Select main file:",
                    format_item = function(item)
                        return item .. (is_main_file(item) and " (has \\documentclass)" or "")
                    end
                }, function(choice)
                    if choice then
                        local filename = vim.fn.fnamemodify(choice, ":t")
                        vim.b.vimtex_main = filename
                        print("VimTeX: Main file set to: " .. filename)
                        vim.cmd('VimtexReload')
                    end
                end)
            else
                print("No .tex files found in project")
            end
        end, vim.tbl_extend('force', opts, { desc = "Set main file manually" }))

        -- Quick main file switching
        vim.keymap.set('n', '<localleader>lf', function()
            local main_candidates = { "main.tex", "document.tex", "thesis.tex", "report.tex" }
            for _, candidate in ipairs(main_candidates) do
                if vim.fn.filereadable(candidate) == 1 then
                    vim.b.vimtex_main = candidate
                    print("VimTeX: Switched to main file: " .. candidate)
                    vim.cmd('VimtexReload')
                    return
                end
            end
            print("VimTeX: No standard main file found")
        end, vim.tbl_extend('force', opts, { desc = "Find and set main file" }))

        -- Reload VimTeX
        vim.keymap.set('n', '<localleader>lr', '<cmd>VimtexReload<cr>',
            vim.tbl_extend('force', opts, { desc = "Reload VimTeX" }))

        -- Show current main file
        vim.keymap.set('n', '<localleader>ls', function()
            local main = vim.b.vimtex_main or "Not set"
            print("VimTeX: Current main file: " .. main)
        end, vim.tbl_extend('force', opts, { desc = "Show current main file" }))
    end,
})

-- Enhanced command to create project-specific latexmkrc
vim.api.nvim_create_user_command('VimtexCreateProjectConfig', function()
    local project_dir = vim.fn.getcwd()
    local latexmkrc_content = [[# Project-specific overrides for optimized compilation
# This file overrides the global ~/.latexmkrc settings

# Inherit global settings first
do glob("~/.latexmkrc");

# Project-specific format file optimization
sub check_project_format {
    my $project_dir = getcwd();
    my $fmt_file = "$project_dir/lualatex-format.fmt";
    return (-e $fmt_file) ? $fmt_file : undef;
}

# Override LuaLaTeX command with project-specific format if available
my $project_fmt = check_project_format();
if ($project_fmt) {
    my $project_dir = getcwd();
    $lualatex = "lualatex -fmt=$project_dir/lualatex-format -synctex=1 -interaction=nonstopmode -file-line-error -halt-on-error %O %S";
    print "Using project-specific LuaLaTeX format file: $project_fmt\n";
}

# Project-specific format file compilation
add_cus_dep('tex', 'fmt', 0, 'compile_lualatex_format');

sub compile_lualatex_format {
    my $base = $_[0];
    if ($base eq 'lualatex-format') {
        my $project_dir = getcwd();
        return system("cd $project_dir && lualatex -ini -jobname='lualatex-format' '&lualatex lualatex-format.tex\\dump'");
    }
    return 0;
}
]]

    local latexmkrc_file = project_dir .. "/.latexmkrc"
    local file = io.open(latexmkrc_file, "w")
    if file then
        file:write(latexmkrc_content)
        file:close()
        print("Project-specific .latexmkrc created: " .. latexmkrc_file)
    else
        print("Error: Could not create .latexmkrc file")
    end
end, { desc = "Create project-specific .latexmkrc configuration" })

-- Auto-command to handle directory changes
vim.api.nvim_create_autocmd("DirChanged", {
    pattern = "*",
    callback = function()
        -- Re-detect main file when changing directories
        if vim.bo.filetype == "tex" then
            vim.cmd("doautocmd FileType tex")
        end
    end,
})
