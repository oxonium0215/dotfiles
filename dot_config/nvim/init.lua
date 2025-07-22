-- Enable faster Lua module loading
vim.loader.enable()

-- Set leader key early
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load core configuration
require("core")

-- Initialize lazy.nvim plugin manager
require("core.lazy")

-- Load configuration based on environment
if vim.g.vscode then
    require("vscode")
else
    -- Load plugins and UI
    require("plugins")
    
    -- Set colorscheme after plugins are loaded
    vim.schedule(function()
        vim.cmd.colorscheme("onedark")
    end)
end
