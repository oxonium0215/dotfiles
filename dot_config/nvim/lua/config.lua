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

-- ヤンク時のハイライト
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Indenting
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- global statusline
vim.opt.laststatus = 3
vim.opt.showmode = false

-- vim.opt.clipboard = "unnamedplus"
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


-- ?─────────────────────────────────────────────────────────────────────────────────?
-- │ ? Disable distribution plugins                                                  │
-- ?─────────────────────────────────────────────────────────────────────────────────?
-- netrwを無効にする
vim.api.nvim_set_var('loaded_netrw', 1)
vim.api.nvim_set_var('loaded_netrwPlugin', 1)

-- disable menu loading
vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu = 1

-- Do not load native syntax completion
vim.g.loaded_syntax_completion = 1

-- Do not load spell files
vim.g.loaded_spellfile_plugin = 1

-- Whether to load netrw by default
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwFileHandlers = 1
-- vim.g.loaded_netrwPlugin = 1
-- vim.g.loaded_netrwSettings = 1
-- newtrw liststyle: https://medium.com/usevim/the-netrw-style-options-3ebe91d42456
vim.g.netrw_liststyle = 3

-- Do not load tohtml.vim
vim.g.loaded_2html_plugin = 1

-- Do not load zipPlugin.vim, gzip.vim and tarPlugin.vim (all these plugins are
-- related to checking files inside compressed files)
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

-- Do not use builtin matchit.vim and matchparen.vim since the use of vim-matchup
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1

-- Disable sql omni completion.
vim.g.loaded_sql_completion = 1

-- Disable EditorConfig support
vim.g.editorconfig = 1

-- Disable remote plugins
-- NOTE: Disabling rplugin.vim will show error for `wilder.nvim` in :checkhealth,
-- NOTE:but since it's config doesn't require python rtp, it's fine to ignore.
-- vim.g.loaded_remote_plugins = 1


-- ?─────────────────────────────────────────────────────────────────────────────────?
-- │ ? Load autocmds                                                                 │
-- ?─────────────────────────────────────────────────────────────────────────────────?
require("core.autocmds")
