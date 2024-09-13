vim.loader.enable()
if vim.loader then vim.loader.enable() end
require("config")
require("core.utils").set_mappings("general")
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
    require("core.utils").lazy(lazypath)
end
vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then
    require("vscode-config")
else
    require("plugins")
    -- colorschemeを設定
    vim.cmd("colorscheme onedark")
end
