local M = {}

local function vscode_action(cmd)
  local ok, vscode = pcall(require, "vscode")
  if ok and vscode.action then
    vscode.action(cmd)
  end
end

M.general = {
  -- better up/down
  { { "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true } },
  { { "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true } },
  { { "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true } },
  { { "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true } },

  -- Move cursor in insert mode
  { "i", "<C-h>", "<Left>", { desc = "move left" } },
  { "i", "<C-l>", "<Right>", { desc = "move right" } },
  { "i", "<C-j>", "<Down>", { desc = "move down" } },
  { "i", "<C-k>", "<Up>", { desc = "move up" } },
  { "i", "jj", "<ESC>", { desc = "escape" } },

  { "n", "<Esc>", "<cmd>noh<CR>", { desc = "General Clear highlights" } },

  -- Don't copy the replaced text after pasting in visual mode
  { "x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Dont copy replaced text", silent = true } },

  -- Redirect change/delete operations to the blackhole
  { { "n", "v" }, "c", '"_c', { desc = "Redirect change to blackhole", silent = true } },
  { { "n", "v" }, "d", '"_d', { desc = "Redirect delete to blackhole", silent = true } },
  { { "n", "v" }, "D", '"_D', { desc = "Redirect delete to blackhole (to EOL)", silent = true } },

  -- Comment (VSCode Action)
  {
    { "n", "v" },
    "<leader>/",
    function()
      vscode_action("editor.action.commentLine")
    end,
    { desc = "Toggle Comment (VSCode)" },
  },

  -- VSCode Native Navigation & Actions (matching Neovim keymaps)
  {
    "n",
    "<leader>ff",
    function()
      vscode_action("workbench.action.quickOpen")
    end,
    { desc = "Find Files (VSCode)" },
  },
  {
    "n",
    "<leader>fg",
    function()
      vscode_action("workbench.action.findInFiles")
    end,
    { desc = "Find in Files (VSCode)" },
  },
  {
    "n",
    "<C-n>",
    function()
      vscode_action("workbench.action.toggleSidebarVisibility")
    end,
    { desc = "Toggle Sidebar (VSCode)" },
  },
  {
    "n",
    "<leader>e",
    function()
      vscode_action("workbench.view.explorer")
    end,
    { desc = "Focus Explorer (VSCode)" },
  },
  {
    "n",
    "<leader>rn",
    function()
      vscode_action("editor.action.rename")
    end,
    { desc = "Rename (VSCode)" },
  },
  {
    "n",
    "<leader>ca",
    function()
      vscode_action("editor.action.quickFix")
    end,
    { desc = "Code Action (VSCode)" },
  },
  {
    "n",
    "gd",
    function()
      vscode_action("editor.action.revealDefinition")
    end,
    { desc = "Go to Definition (VSCode)" },
  },
  {
    "n",
    "gr",
    function()
      vscode_action("editor.action.goToReferences")
    end,
    { desc = "Go to References (VSCode)" },
  },
  {
    "n",
    "<leader>fm",
    function()
      vscode_action("editor.action.formatDocument")
    end,
    { desc = "Format Document (VSCode)" },
  },
  {
    "n",
    "<leader>x",
    function()
      vscode_action("workbench.actions.view.problems")
    end,
    { desc = "Show Problems (VSCode)" },
  },
  {
    "n",
    "<leader>t",
    function()
      vscode_action("workbench.action.terminal.toggleTerminal")
    end,
    { desc = "Toggle Terminal (VSCode)" },
  },
}

M.hop = {
  {
    "n",
    "f",
    "<cmd>lua require('hop').hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true })<CR>",
    { desc = "Hop forward to character", remap = true },
  },
  {
    "n",
    "F",
    "<cmd>lua require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true })<CR>",
    { desc = "Hop backward to character", remap = true },
  },
  {
    "n",
    "t",
    "<cmd>lua require('hop').hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<CR>",
    { desc = "Hop forward to character (t)", remap = true },
  },
  {
    "n",
    "T",
    "<cmd>lua require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<CR>",
    { desc = "Hop backward to character (T)", remap = true },
  },
}

return M
