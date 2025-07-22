-- VSCode-compatible keymaps
local map = vim.keymap.set

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ General Keymaps (VSCode Compatible)                                             │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

-- Better up/down movement (handles wrapped lines)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Insert mode navigation
map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })

-- Clear search highlights
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })

-- Line numbers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle relative number" })

-- Buffer management
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "New buffer" })

-- Better paste in visual mode
map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Paste without copying replaced text", silent = true })

-- Comments
map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })

-- Diagnostics
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "Diagnostic loclist" })