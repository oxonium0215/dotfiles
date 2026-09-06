local utils = require("core.utils")

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "" },
      change = { text = "" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "" },
      untracked = { text = "" },
    },
    current_line_blame = true,
    on_attach = function(bufnr)
      utils.set_mappings("gitsigns", { buffer = bufnr })
    end,
  },
}
