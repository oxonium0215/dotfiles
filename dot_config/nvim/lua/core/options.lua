-- Neovim options and settings
local opt = vim.opt
local g = vim.g

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ General Settings                                                                │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

-- Disable some default providers
for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
    g["loaded_" .. provider .. "_provider"] = 0
end

-- Disable default menus
g.did_install_default_menus = 1

-- Set tex flavor to latex
g.tex_flavor = "latex"

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ UI Settings                                                                     │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

-- Line numbers
opt.number = true
opt.numberwidth = 2
opt.ruler = false

-- Search
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true

-- Mouse and clipboard
opt.mouse = "a"

-- Undo and backup
opt.undofile = true

-- Indentation
opt.breakindent = true
opt.startofline = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- UI elements
opt.signcolumn = "yes"
opt.cursorline = true
opt.laststatus = 3  -- Global statusline
opt.showmode = false
opt.fillchars = { eob = " " }

-- Timing
opt.updatetime = 250
opt.timeoutlen = 400

-- Completion
opt.completeopt = "menuone,noselect"

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Colors
opt.termguicolors = true

-- Navigation
opt.whichwrap:append("<>[]hl")

-- Disable nvim intro
opt.shortmess:append("sI")

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ Diagnostic Configuration                                                        │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

local icons = require("core.icons")
local diagnostic_icons = icons.get("diagnostics")

-- Define icons for each diagnostic severity
local signs = {
    [vim.diagnostic.severity.ERROR] = diagnostic_icons.Error,
    [vim.diagnostic.severity.WARN] = diagnostic_icons.Warning,
    [vim.diagnostic.severity.INFO] = diagnostic_icons.Information,
    [vim.diagnostic.severity.HINT] = diagnostic_icons.Hint,
}

-- Configure diagnostic display
vim.diagnostic.config({
    virtual_text = {
        prefix = function(diagnostic)
            return signs[diagnostic.severity]
        end,
    },
})

-- Set diagnostic signs
for name, icon in pairs({
    Error = diagnostic_icons.Error,
    Warn = diagnostic_icons.Warning,
    Info = diagnostic_icons.Information,
    Hint = diagnostic_icons.Hint,
}) do
    local hl = "DiagnosticSign" .. name
    vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ Path Configuration                                                              │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

-- Add mason binaries to PATH
local is_windows = vim.uv.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH