---@type Terminal?
local saved_terminal

return {
  "willothy/flatten.nvim",
  lazy = false,
  priority = 1001,
  opts = {
    window = {
      open = "alternate",
    },
    hooks = {
      pre_open = function()
        local ok_term, term = pcall(require, "toggleterm.terminal")
        if ok_term then
          local termid = term.get_focused_id()
          saved_terminal = term.get(termid)
        end
      end,
      post_open = function(bufnr, winnr, ft, is_blocking)
        if is_blocking and saved_terminal then
          -- Hide the terminal while editing a blocking file (e.g. git commit, git rebase)
          saved_terminal:close()
        elseif winnr and vim.api.nvim_win_is_valid(winnr) then
          vim.api.nvim_set_current_win(winnr)
        end
      end,
      block_end = function()
        -- Reopen terminal after finishing the blocking file edit
        if saved_terminal then
          saved_terminal:open()
          saved_terminal = nil
        end
      end,
    },
  },
}
