-- ハイライトオンサーチ
vim.o.hlsearch = false

-- 行番号を表示
vim.wo.number = true

-- マウスモードを有効化
vim.o.mouse = 'a'

-- undoヒストリーを保存
vim.o.undofile = true

-- ブレークインデント、startoflineを有効化
vim.o.breakindent = true
vim.opt.startofline = true

-- 検索
vim.o.ignorecase = true
vim.o.smartcase = true

-- SignColumn
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 400

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

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
vim.opt.shortmess:append "sI"

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
--vim.opt.winblend = 0
--vim.opt.pumblend = 0

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
vim.opt.whichwrap:append "<>[]hl"

vim.g.mapleader = " "

-- disable some default providers
for _, provider in ipairs { "node", "perl", "python3", "ruby" } do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ ∘ Load autocmds                                                                 │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯
require("core.autocmds")
