-- Redirect Windows Neovim config to ~/.config/nvim
local home = vim.fn.expand("~"):gsub("\\", "/")
local config_dir = home .. "/.config/nvim"

vim.opt.runtimepath:prepend(config_dir)
vim.opt.runtimepath:append(config_dir .. "/after")
vim.opt.packpath:prepend(config_dir)

local init_file = config_dir .. "/init.lua"
local uv = vim.uv or vim.loop
if uv.fs_stat(init_file) then
  dofile(init_file)
else
  vim.notify("Could not find ~/.config/nvim/init.lua at " .. init_file, vim.log.levels.ERROR)
end
