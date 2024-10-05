vim.loader.enable()
if vim.loader then vim.loader.enable() end
require("config")
require("core.utils").set_mappings("general")
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46_cache/"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
    require("core.utils").lazy(lazypath)
end
vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then
    require("vscode-config")
else
    require("plugins")
    -- vim.cmd("colorscheme onedark")
    dofile(vim.g.base46_cache .. "syntax")
    dofile(vim.g.base46_cache .. "defaults")
    dofile(vim.g.base46_cache .. "statusline")
end
