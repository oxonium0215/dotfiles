-- Neovim keymaps configuration
-- Organized by functionality for better maintainability

local map = vim.keymap.set

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ General Keymaps                                                                 │
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
map("i", "jj", "<ESC>", { desc = "Escape insert mode" })

-- Clear search highlights
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })

-- Line numbers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle relative number" })

-- Buffer management
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "New buffer" })

-- Better paste in visual mode (don't copy replaced text)
map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Paste without copying replaced text", silent = true })

-- Comments
map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ LSP Keymaps                                                                     │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

-- Navigation
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

-- Information
map("n", "K", vim.lsp.buf.hover, { desc = "Show hover information" })
map("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "Show signature help" })

-- Actions
map("n", "<leader>ra", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<leader>f", function() 
    if vim.fn.exists(":Format") > 0 then
        vim.cmd("Format")
    else
        vim.lsp.buf.format({ async = true })
    end
end, { desc = "Format buffer" })

-- Diagnostics
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "Diagnostic loclist" })
map("n", "[d", function()
    vim.diagnostic.goto_prev({ float = { border = "rounded" } })
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
    vim.diagnostic.goto_next({ float = { border = "rounded" } })
end, { desc = "Next diagnostic" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic setloclist" })

-- Workspace
map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List workspace folders" })

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ Window Management                                                               │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯

-- Window picker (requires nvim-window plugin)
map("n", "<C-w>", function()
    require("nvim-window").pick()
end, { desc = "Pick window", silent = true })
map("t", "<C-w>", function()
    require("nvim-window").pick()
end, { desc = "Pick window", silent = true })

-- ╭─────────────────────────────────────────────────────────────────────────────────╮
-- │ Plugin-specific keymaps will be loaded by their respective configurations      │
-- ╰─────────────────────────────────────────────────────────────────────────────────╯