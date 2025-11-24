local M = {}

M.general = {
  -- better up/down
  {{ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true }},
  {{ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true }},
  {{ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true }},
  {{ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true }},

  -- Move to window using the <ctrl> hjkl keys
  {"i", "<C-h>", "<Left>", { desc = "move left" }},
  {"i", "<C-l>", "<Right>", { desc = "move right" }},
  {"i", "<C-j>", "<Down>", { desc = "move down" }},
  {"i", "<C-k>", "<Up>", { desc = "move up" }},

  {"n", "<Esc>", "<cmd>noh<CR>", { desc = "General Clear highlights" }},

  -- line number
  {"n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle line number" }},
  {"n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle relative number" }},

  -- cheatsheet
  -- {"n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "Toggle nvcheatsheet" }}

  -- global lsp mappings
  {"n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP Diagnostic loclist" }},

  -- buffer
  {"n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" }},
  -- Don't copy the replaced text after pasting in visual mode
  -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
  {"x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Dont copy replaced text", silent = true }},

  --  Redirect change operations to the blackhole to avoid spoiling 'y' register content
  {{"n", "v"}, "c", '"_c', { desc = "Redirect change to blackhole", silent = true }},
  {{"n", "v"}, "d", '"_d', { desc = "Redirect delete to blackhole", silent = true }},
  {{"n", "v"}, "D", '"_D', { desc = "Redirect delete to blackhole (to EOL)", silent = true }},

  -- Comment
  {"n", "<leader>/", "gcc", { desc = "Toggle Comment", remap = true }},
  {"v", "<leader>/", "gc", { desc = "Toggle comment", remap = true }},
}

M.oil = {
    {"n", "<leader>o", "<cmd>Oil<CR>", { desc = "Open oil" }},
}

M.pounce = {
  {"n", "s", "<cmd>Pounce<CR>", { desc = "Pounce" }},
  {"n", "S", "<cmd>PounceRepeat<CR>", { desc = "Pounce Repeat" }},
  {"o", "gs", "<cmd>Pounce<CR>", { desc = "Pounce" }},
  {"x", "s", "<cmd>Pounce<CR>", { desc = "Pounce" }},
}

M.hop = {
  {"n", "f", "<cmd>lua require('hop').hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true })<CR>", { desc = "Hop forward to character", remap = true }},
  {"n", "F", "<cmd>lua require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true })<CR>", { desc = "Hop backward to character", remap = true }},
  {"n", "t", "<cmd>lua require('hop').hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<CR>", { desc = "Hop forward to character (t)", remap = true }},
  {"n", "T", "<cmd>lua require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<CR>", { desc = "Hop backward to character (T)", remap = true }},
}

return M
