local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local config_root = vim.fn.stdpath("config")

local groups = {
    general = augroup("GeneralSettings", { clear = true }),
    nvimtree = augroup("NvimTreeClose", { clear = true }),
    close_ft = augroup("CloseFiletypesWithQ", { clear = true }),
    telescope = augroup("TelescopeFix", { clear = true }),
    bufs = augroup("BufferActions", { clear = true }),
    wins = augroup("WindowActions", { clear = true }),
    ft = augroup("FileTypeSettings", { clear = true }),
    yank = augroup("YankHighlight", { clear = true }),
}

local function create_autocmd(event, opts)
    opts.group = groups[opts.group]
    autocmd(event, opts)
end

-- Lazy load clipboard
create_autocmd({ "BufReadPost", "BufNewFile" }, {
  once = true,
  callback = function()
    local provider_set = false
    if vim.fn.has("macunix") == 1 or vim.fn.has("mac") == 1 then
      provider_set = true -- use built-in mac clipboard provider
    end

    if not provider_set and (vim.fn.has("win32") == 1 or vim.fn.has("wsl") == 1) then
      if vim.fn.executable("win32yank.exe") == 1 then
        vim.g.clipboard = {
          copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
          },
          paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
          },
        }
        provider_set = true
      end
    end

    if not provider_set and vim.fn.has("unix") == 1 then
      if vim.fn.executable("xclip") == 1 then
        vim.g.clipboard = {
          copy = {
            ["+"] = "xclip -selection clipboard",
            ["*"] = "xclip -selection clipboard",
          },
          paste = {
            ["+"] = "xclip -selection clipboard -o",
            ["*"] = "xclip -selection clipboard -o",
          },
        }
        provider_set = true
      elseif vim.fn.executable("xsel") == 1 then
        vim.g.clipboard = {
          copy = {
            ["+"] = "xsel --clipboard --input",
            ["*"] = "xsel --clipboard --input",
          },
          paste = {
            ["+"] = "xsel --clipboard --output",
            ["*"] = "xsel --clipboard --output",
          },
        }
        provider_set = true
      end
    end
    if provider_set then
      vim.opt.clipboard = "unnamedplus"
    end
  end,
  group = "general",
  desc = "Lazy load clipboard",
})

-- Auto close NvimTree when it's the last window
create_autocmd("BufEnter", {
    pattern = "NvimTree_*",
    callback = function()
        local layout = vim.fn.winlayout()
        if layout[1] == "leaf"
            and vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(layout[2]) }) == "NvimTree"
            and not layout[3] then
            vim.cmd("confirm quit")
        end
    end,
    group = "nvimtree",
    desc = "Auto close NvimTree when it's the last window",
})

-- Auto close specific filetypes with <q>
local filetypes_to_close = {
    "qf", "help", "man", "notify", "nofile", "lspinfo",
    "terminal", "prompt", "toggleterm", "copilot", "startuptime",
    "tsplayground", "PlenaryTestPopup",
}

create_autocmd("FileType", {
    pattern = filetypes_to_close,
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
            buffer = event.buf,
            silent = true,
            noremap = true,
            nowait = true,
        })
    end,
    group = "close_ft",
    desc = "Close specific filetypes with <q>",
})

-- Fix fold issue with files opened by Telescope
create_autocmd("BufRead", {
    callback = function()
        create_autocmd("BufWinEnter", {
            once = true,
            command = "normal! zx",
            group = "telescope",
        })
    end,
    group = "telescope",
    desc = "Fix fold issue with files opened by Telescope",
})

-- Buffer-related Autocommands
create_autocmd("BufWritePost", {
    pattern = config_root .. "/**/*.vim",
    callback = function()
        vim.cmd("silent! source $MYVIMRC")
        vim.cmd("redraw")
    end,
    group = "bufs",
    desc = "Reload vim config automatically",
})

create_autocmd("BufWritePost", {
    pattern = "*.vim",
    command = "nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif",
    group = "bufs",
    desc = "Reload Vim script automatically if setlocal autoread",
})

create_autocmd("BufWritePre", {
    pattern = { "/tmp/*", "COMMIT_EDITMSG", "MERGE_MSG", "*.tmp", "*.bak" },
    command = "setlocal noundofile",
    group = "bufs",
    desc = "Disable undofile for specific buffers",
})

create_autocmd("BufReadPost", {
    pattern = "*",
    command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]],
    group = "bufs",
    desc = "Auto place to last edit",
})

-- Window-related Autocommands
create_autocmd({ "WinEnter", "BufEnter", "InsertLeave" }, {
    pattern = "*",
    command = [[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]],
    group = "wins",
    desc = "Highlight current line only on focused window",
})

create_autocmd({ "WinLeave", "BufLeave", "InsertEnter" }, {
    pattern = "*",
    command = [[if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif]],
    group = "wins",
    desc = "Remove highlight from current line when unfocused",
})

create_autocmd("VimLeave", {
    pattern = "*",
    command = [[if has('nvim') | wshada | else | wviminfo! | endif]],
    group = "wins",
    desc = "Attempt to write shada when leaving nvim",
})

create_autocmd("FocusGained", {
    pattern = "*",
    command = "checktime",
    group = "wins",
    desc = "Check if file changed when its window is focused",
})

create_autocmd("VimResized", {
    pattern = "*",
    command = "tabdo wincmd =",
    group = "wins",
    desc = "Equalize window dimensions when resizing vim window",
})

-- FileType-specific Autocommands
create_autocmd("FileType", {
    pattern = "alpha",
    command = "set showtabline=0",
    group = "ft",
    desc = "Hide tabline for alpha filetype",
})

create_autocmd("FileType", {
    pattern = "markdown",
    command = "set wrap",
    group = "ft",
    desc = "Enable wrap for markdown",
})

create_autocmd("FileType", {
    pattern = "make",
    command = "set noexpandtab shiftwidth=8 softtabstop=0",
    group = "ft",
    desc = "Set tab settings for make filetype",
})

create_autocmd("FileType", {
    pattern = "dap-repl",
    command = "lua require('dap.ext.autocompl').attach()",
    group = "ft",
    desc = "Attach dap autocompletion",
})

create_autocmd("FileType", {
    pattern = "*",
    command = "setlocal formatoptions-=cro",
    group = "ft",
    desc = "Disable auto-commenting on newline",
})

-- Yank Highlight Autocommand
create_autocmd("TextYankPost", {
    pattern = "*",
    command = "silent! lua vim.highlight.on_yank({higroup='IncSearch', timeout=100})",
    group = "yank",
    desc = "Highlight text on yank",
})

-- Show line diagnostics automatically in hover window
create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
  callback = function ()
    if vim.api.nvim_get_mode().mode ~= 'i' then
      vim.diagnostic.open_float(nil, {focus=false})
    end
  end
})
