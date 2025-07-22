-- Core Neovim configuration
-- This module loads all essential configuration components

-- Load core modules in order
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Load specialized modules
require("core.japanese").setup_japanese_input()
require("core.japanese").setup_japanese_snippets()