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
  {"i", "jj", "<ESC>", { desc = "escape" }},

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

  -- Comment
  {"n", "<leader>/", "gcc", { desc = "Toggle Comment", remap = true }},
  {"v", "<leader>/", "gc", { desc = "Toggle comment", remap = true }},
}

M.bufferline = {
  {"n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle pin" }},
  {"n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete non-pinned buffers" }},
  {"n", "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Delete other buffers" }},
  {"n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Delete buffers to the right" }},
  {"n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Delete buffers to the left" }},
  {"n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" }},
  {"n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" }},
}

M.lspconfig = {
  {"n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "LSP declaration" }},
  {"n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "LSP definition" }},
  {"n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "LSP hover" }},
  {"n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "LSP implementation" }},
  {"n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", { desc = "LSP signature help" }},
  {"n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "LSP definition type" }},
  {"n", "<leader>ra", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "LSP rename" }},
  {"n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "LSP code action" }},
  {"n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "LSP references" }},
  {"n", "<leader>f", "<cmd>lua smart_format()<CR>", { desc = "Format current buffer" }},
  {"n", "[d", "<cmd>lua vim.diagnostic.goto_prev { float = { border = 'rounded' } }<CR>", { desc = "Goto prev" }},
  {"n", "]d", "<cmd>lua vim.diagnostic.goto_next { float = { border = 'rounded' } }<CR>", { desc = "Goto next" }},
  {"n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", { desc = "Diagnostic setloclist" }},
  {"n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", { desc = "Add workspace folder" }},
  {"n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", { desc = "Remove workspace folder" }},
  {"n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", { desc = "List workspace folders" }},
}

M.trouble = {
    {"n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Trouble diagnostic toggle" }},
    {"n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble diagnostics toggle (Buffer)" }},
    {"n", "<leader>cs", "<cmd>Trouble symbols toggle<CR>", { desc = "Trouble symbols toggle" }},
    {"n", "<leader>cS", "<cmd> Trouble lsp toggle<CR>", { desc = "LSP references/definitions/..." }},
    {"n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" }},
    {"n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" }},
}

M.dap = {
  {"n", "<F5>", "<cmd>lua require('dap').continue()<CR>", { desc = "Debug: Start/Continue" }},
  {"n", "<F1>", "<cmd>lua require('dap').step_into()<CR>", { desc = "Debug: Step Into" }},
  {"n", "<F2>", "<cmd>lua require('dap').step_over()<CR>", { desc = "Debug: Step Over" }},
  {"n", "<F3>", "<cmd>lua require('dap').step_out()<CR>", { desc = "Debug: Step Out" }},
  {"n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<CR>", { desc = "Debug: Toggle Breakpoint" }},
  {"n", "<leader>B", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { desc = "Debug: Set Breakpoint with Condition" }},
}

M.codecompanion = {
    {"n", "<leader>cf", "<cmd>CodeCompanion<CR>", { desc = "Open CodeCompanion" }},
    {"n", "<leader>cc", "<cmd>CodeCompanionChat<CR>", { desc = "Open CodeCompanion Chat" }},
    {"n", "<leader>cl", "<cmd>CodeCompanionActions<CR>", { desc = "Open CodeCompanion Inline" }},
}

M.nvimtree = {
  {"n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" }},
  {"n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" }},
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

M.notify = {
  {"n", "<leader>un", function()
    require("notify").dismiss({ silent = true, pending = true })
  end,{ desc = "Dismiss All Notifications"}
  },
}

M.nvimwindow = {
  {"n", "<C-w>", "<cmd>lua require('nvim-window').pick()<CR>", { desc = "Window picker", silent = true }},
  {"t", "<C-w>", "<cmd>lua require('nvim-window').pick()<CR>", { desc = "Window picker", silent = true }},
}

M.fzf = {
  {"n", "<leader>fg", "<cmd>lua require('fzf-lua').live_grep()<CR>", { desc = "fzf-lua live grep" }},
  {"n", "<leader>fb", "<cmd>lua require('fzf-lua').buffers()<CR>", { desc = "fzf-lua find buffers" }},
  {"n", "<leader>fh", "<cmd>lua require('fzf-lua').help_tags()<CR>", { desc = "fzf-lua help page" }},
  {"n", "<leader>ma", "<cmd>lua require('fzf-lua').marks()<CR>", { desc = "fzf-lua find marks" }},
  {"n", "<leader>fo", "<cmd>lua require('fzf-lua').oldfiles()<CR>", { desc = "fzf-lua find oldfiles" }},
  {"n", "<leader>fz", "<cmd>lua require('fzf-lua').grep_curbuf()<CR>", { desc = "fzf-lua find in current buffer" }},
  {"n", "<leader>cm", "<cmd>lua require('fzf-lua').git_commits()<CR>", { desc = "fzf-lua git commits" }},
  {"n", "<leader>gt", "<cmd>lua require('fzf-lua').git_status()<CR>", { desc = "fzf-lua git status" }},
  {"n", "<leader>pt", "<cmd>lua require('fzf-lua').builtin()<CR>", { desc = "fzf-lua pick hidden term" }},
  {"n", "<leader>th", "<cmd>lua require('fzf-lua').colorschemes()<CR>", { desc = "fzf-lua themes" }},
  {"n", "<leader>ff", "<cmd>lua require('fzf-lua').files()<CR>", { desc = "fzf-lua find files" }},
  {"n", "<leader>fa", "<cmd>lua require('fzf-lua').files({ no_ignore = true, hidden = true, follow = true })<CR>", { desc = "fzf-lua find all files" }},
}

M.telescope = {
  {"n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" }},
  {"n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" }},
  {"n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" }},
  {"n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" }},
  {"n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" }},
  {"n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" }},
  {"n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" }},
  {"n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" }},
  {"n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" }},
  {"n", "<leader>th", "<cmd>Telescope themes<CR>", { desc = "telescope themes" }},
  {"n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" }},
  {"n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", { desc = "telescope find all files" }},
}

M.vimtex = {
  {"n", "<leader>ll", "<cmd>VimtexCompile<CR>", { desc = "LaTeX compile" }},
  {"n", "<leader>lv", "<cmd>VimtexView<CR>", { desc = "LaTeX view PDF" }},
  {"n", "<leader>lt", "<cmd>VimtexTocToggle<CR>", { desc = "LaTeX TOC toggle" }},
  {"n", "<leader>lc", "<cmd>VimtexClean<CR>", { desc = "LaTeX clean aux files" }},
  {"n", "<leader>lC", "<cmd>VimtexClean!<CR>", { desc = "LaTeX clean all files" }},
  {"n", "<leader>ls", "<cmd>VimtexStop<CR>", { desc = "LaTeX stop compiler" }},
  {"n", "<leader>lS", "<cmd>VimtexStopAll<CR>", { desc = "LaTeX stop all compilers" }},
  {"n", "<leader>le", "<cmd>VimtexErrors<CR>", { desc = "LaTeX show errors" }},
  {"n", "<leader>lo", "<cmd>VimtexCompileOutput<CR>", { desc = "LaTeX show output" }},
  {"n", "<leader>lg", "<cmd>VimtexStatus<CR>", { desc = "LaTeX show status" }},
  {"n", "<leader>lG", "<cmd>VimtexStatusAll<CR>", { desc = "LaTeX show all status" }},
  {"n", "<leader>lk", "<cmd>VimtexStopAll<CR>", { desc = "LaTeX kill all processes" }},
  {"n", "<leader>lr", "<cmd>VimtexReload<CR>", { desc = "LaTeX reload" }},
  {"n", "<leader>la", "<cmd>VimtexContextMenu<CR>", { desc = "LaTeX context menu" }},
  -- New format file commands
  {"n", "<leader>lfp", "<cmd>VimtexCreateProjectFormat<CR>", { desc = "Create project format file" }},
  {"n", "<leader>lfg", "<cmd>VimtexCreateGlobalFormat<CR>", { desc = "Create global format file" }},
}

M.toggleterm = {
  {"n", "<A-v>", "<cmd>lua require('core.utils').toggleTerm('vertical')<CR>", { desc = "toggle vertical term" }},
  {"t", "<A-v>", "<cmd>lua require('core.utils').toggleTerm('vertical')<CR>", { desc = "toggle vertical term" }},
  {"n", "<A-h>", "<cmd>lua require('core.utils').toggleTerm('horizontal')<CR>", { desc = "toggle horizontal term" }},
  {"t", "<A-h>", "<cmd>lua require('core.utils').toggleTerm('horizontal')<CR>", { desc = "toggle horizontal term" }},
  {"n", "<A-i>", "<cmd>lua require('core.utils').toggleTerm('float')<CR>", { desc = "toggle floating term" }},
  {"t", "<A-i>", "<cmd>lua require('core.utils').toggleTerm('float')<CR>", { desc = "toggle floating term" }},
}

M.blankline = {
  {"n", "<leader>cc", "<cmd>lua require('ibl.scope').get(vim.api.nvim_get_current_buf(), { scope = { exclude = { language = {}, node_type = {} }, include = { node_type = {} } } }):range() and vim.api.nvim_win_set_cursor(0, { require('ibl.scope').get(vim.api.nvim_get_current_buf(), { scope = { exclude = { language = {}, node_type = {} }, include = { node_type = {} } } }):range()[1] + 1, 0 })<CR>", { desc = "blankline jump to current context" }},
}

M.searchbox = {
  {"n", "?", "<cmd> SearchBoxIncSearch <CR>", { desc = "Open float searchbox" }},
}

M.cmdline = {
  {"n", ":", "<cmd>FineCmdline<CR>", { desc = "Open float cmdline" }},
}

M.overseer = {
  {"n", "<leader><F5>", "<cmd> OverseerRun <CR>", { desc = "Run tasks" }},
  {"i", "<leader><F5>", "<cmd> OverseerRun <CR>", { desc = "Run tasks" }},
}

M.gitsigns = {
  {"n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        require("gitsigns").next_hunk()
      end)
      return "<Ignore>"
    end, { desc = "Jump to next hunk", expr = true }
  },

  {"n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        require("gitsigns").prev_hunk()
      end)
      return "<Ignore>"
    end, { desc = "Jump to prev hunk", expr = true }
  },

  {"n", "<leader>rh", function()
      require("gitsigns").reset_hunk()
    end, { desc = "Reset hunk" }
  },

  {"n", "<leader>ph", function()
      require("gitsigns").preview_hunk()
    end, { desc = "Preview hunk" }
  },

  {"n", "<leader>gb", function()
      package.loaded.gitsigns.blame_line()
    end, { desc = "Blame line" }
  },

  {"n", "<leader>td", function()
      require("gitsigns").toggle_deleted()
    end, { desc = "Toggle deleted" }
  },
}

return M
