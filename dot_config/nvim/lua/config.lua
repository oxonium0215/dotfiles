local icons = require("core.icons")
local uv = vim.uv or vim.loop

-- Default: enable format-on-save toggle unless user overrides before this loads
if vim.g.autoformat_enabled == nil then
  vim.g.autoformat_enabled = true
end

-- highlight on search
vim.o.hlsearch = false

-- show line number globally
vim.opt.number = true

-- enable mouse mode
vim.o.mouse = "a"

-- save undo history
vim.o.undofile = true

vim.o.breakindent = true
vim.opt.startofline = true

-- search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.opt.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 400

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Indenting
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- global statusline
vim.opt.laststatus = 3
vim.opt.showmode = false

vim.opt.cursorline = true

vim.opt.fillchars = { eob = " " }

-- Numbers
vim.opt.numberwidth = 2
vim.opt.ruler = false

-- disable nvim intro
vim.opt.shortmess:append("sI")

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
--vim.opt.winblend = 0
--vim.opt.pumblend = 0

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
vim.opt.whichwrap:append("<>[]hl")

vim.g.mapleader = " "

-- Get diagnostic icons
local diagnostic_icons = icons.get("diagnostics")

-- Define icons for each diagnostic severity using icons.get
local signs = {
  [vim.diagnostic.severity.ERROR] = diagnostic_icons.Error,
  [vim.diagnostic.severity.WARN] = diagnostic_icons.Warning,
  [vim.diagnostic.severity.INFO] = diagnostic_icons.Information,
  [vim.diagnostic.severity.HINT] = diagnostic_icons.Hint,
}

-- Configure diagnostic display
vim.diagnostic.config({
  signs = {
    text = signs,
  },
  virtual_text = {
    prefix = function(diagnostic)
      return signs[diagnostic.severity]
    end,
  },
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  float = { border = "rounded" },
})

-- disable some default providers
for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

-- add binaries installed by mason.nvim to path
local is_windows = uv.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH

-- set font for gui clients
if vim.fn.has('gui_running') == 1 then
  vim.o.guifont = "HackGen Console NF:h14"
end

vim.g.did_install_default_menus = 1

-- set tex flavor to latex
vim.g.tex_flavor = "latex"

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ ∘ Load autocmds                                                                 │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯
require("core.autocmds")
