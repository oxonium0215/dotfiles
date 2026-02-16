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

-- Clipboard provider setup (with deferred sync for external-process providers)
-- Native API providers (macOS, Windows) use clipboard=unnamedplus directly.
-- External process providers (win32yank, xclip, xsel, OSC 52) use deferred
-- sync via FocusLost/FocusGained to avoid per-operation latency.
-- Priority: macOS > Windows native > WSL (win32yank) > X11/Wayland > OSC 52
create_autocmd({ "BufReadPost", "BufNewFile" }, {
  once = true,
  callback = function()
    -- use_native: clipboard API is in-process (no external tool latency)
    local use_native = false
    local provider_set = false

    -- 1. macOS: built-in provider (native API, no latency)
    if vim.fn.has("macunix") == 1 or vim.fn.has("mac") == 1 then
      use_native = true
      provider_set = true
    end

    -- 2. Windows native (nvy, Neovide, etc.): built-in provider (Win32 API)
    if not provider_set and vim.fn.has("win32") == 1 and vim.fn.has("wsl") == 0 then
      use_native = true
      provider_set = true
    end

    -- 3. WSL: win32yank.exe (external process)
    if not provider_set and vim.fn.has("wsl") == 1 then
      if vim.fn.executable("win32yank.exe") == 1 then
        vim.g.clipboard = {
          name = "win32yank-wsl",
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

    -- 4. Unix with X11/Wayland: xclip or xsel (external process)
    if not provider_set and vim.fn.has("unix") == 1 then
      if vim.fn.executable("xclip") == 1 then
        vim.g.clipboard = {
          name = "xclip",
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
          name = "xsel",
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

    -- 5. Fallback: OSC 52 (works over SSH, tmux, etc.)
    if not provider_set and vim.fn.has("nvim-0.10") == 1 then
      local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
      if ok then
        vim.g.clipboard = {
          name = "OSC 52",
          copy = {
            ["+"] = osc52.copy("+"),
            ["*"] = osc52.copy("*"),
          },
          paste = {
            ["+"] = osc52.paste("+"),
            ["*"] = osc52.paste("*"),
          },
        }
        provider_set = true
      end
    end

    if not provider_set then
      return
    end

    -- Native providers: use clipboard=unnamedplus directly (no latency)
    if use_native then
      vim.opt.clipboard = "unnamedplus"
      return
    end

    -- External providers: deferred sync via focus events to avoid latency
    local last_synced = nil

    local deferred_clip_group = vim.api.nvim_create_augroup("DeferredClipboardSync", { clear = true })

    -- Write: " register → + register on focus lost / exit
    vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
      group = deferred_clip_group,
      callback = function()
        local content = vim.fn.getreg('"')
        if content ~= "" and content ~= last_synced then
          vim.fn.setreg("+", content)
          last_synced = content
        end
      end,
      desc = "Deferred clipboard: write to system clipboard",
    })

    -- Read: + register → " register on focus gained
    vim.api.nvim_create_autocmd("FocusGained", {
      group = deferred_clip_group,
      callback = function()
        vim.defer_fn(function()
          local content = vim.fn.getreg("+")
          if content ~= "" then
            vim.fn.setreg('"', content)
            last_synced = content
          end
        end, 10)
      end,
      desc = "Deferred clipboard: read from system clipboard",
    })

    -- Initial read at startup
    vim.schedule(function()
      local content = vim.fn.getreg("+")
      if content ~= "" then
        vim.fn.setreg('"', content)
        last_synced = content
      end
    end)
  end,
  group = "general",
  desc = "Clipboard provider setup with OS detection",
})

-- Auto close NvimTree when it's the last window
create_autocmd("BufEnter", {
  pattern = "NvimTree_*",
  callback = function()
    local layout = vim.fn.winlayout()
    if
      layout[1] == "leaf"
      and vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(layout[2]) }) == "NvimTree"
      and not layout[3]
    then
      vim.cmd("confirm quit")
    end
  end,
  group = "nvimtree",
  desc = "Auto close NvimTree when it's the last window",
})

-- Auto close specific filetypes with <q>
local filetypes_to_close = {
  "qf",
  "help",
  "man",
  "notify",
  "nofile",
  "lspinfo",
  "terminal",
  "prompt",
  "toggleterm",
  "copilot",
  "startuptime",
  "tsplayground",
  "PlenaryTestPopup",
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
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "i" then
      vim.diagnostic.open_float(nil, { focus = false })
    end
  end,
})

-- ╭──────────────────────────────────────────────────────────────────────────────╮
-- │ LSP Idle Timeout - Stop inactive LSP servers to free RAM                     │
-- ╰──────────────────────────────────────────────────────────────────────────────╯
local lsp_idle = augroup("LspIdleTimeout", { clear = true })
local lsp_idle_timer = nil
local lsp_idle_timeout = 1000 * 60 * 15 -- 15 minutes

autocmd("FocusLost", {
  group = lsp_idle,
  callback = function()
    if lsp_idle_timer then
      lsp_idle_timer:stop()
    end
    lsp_idle_timer = vim.defer_fn(function()
      local clients = vim.lsp.get_clients()
      for _, client in ipairs(clients) do
        client:stop()
      end
      if #clients > 0 then
        vim.notify(
          string.format("Stopped %d idle LSP client(s) to free RAM", #clients),
          vim.log.levels.INFO
        )
      end
    end, lsp_idle_timeout)
  end,
  desc = "Start timer to stop LSP servers after focus lost",
})

autocmd("FocusGained", {
  group = lsp_idle,
  callback = function()
    if lsp_idle_timer then
      lsp_idle_timer:stop()
      lsp_idle_timer = nil
    end
    -- LSP will be restarted automatically by existing FileType autocmd
  end,
  desc = "Cancel LSP idle timer on focus gained",
})
