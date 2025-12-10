vim.loader.enable()
require("config")
local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not uv.fs_stat(lazypath) then
  require("core.utils").lazy(lazypath)
end
vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then
  require("vscode-config")
else
  require("core.utils").set_mappings("general")
  require("plugins")
  -- colorschemeを設定
  vim.cmd("colorscheme onedark")
  require("core.japanese").setup_japanese_input()
  require("core.lazy_install").setup()
end
