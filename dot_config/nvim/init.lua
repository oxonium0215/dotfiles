vim.loader.enable()
if vim.loader then vim.loader.enable() end
require("config")
require("core.utils").load_mappings()
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
    require("core.utils").lazy(lazypath)
end
vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then
    require("vscode")
else
    require("plugins")
    -- colorschemeを設定
    --vim.cmd("colorscheme onedark")
end
