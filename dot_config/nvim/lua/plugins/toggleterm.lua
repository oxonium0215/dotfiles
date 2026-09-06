local utils = require("core.utils")

local function get_default_shell()
  if vim.fn.executable("pwsh") == 1 then
    return "pwsh"
  elseif vim.fn.executable("powershell") == 1 then
    return "powershell"
  elseif vim.fn.has("win32") == 1 then
    return "powershell.exe"
  end
  return vim.o.shell
end

return {
  "akinsho/toggleterm.nvim",
  keys = utils.generate_lazy_keys("toggleterm"),
  cmd = {
    "ToggleTerm",
    "ToggleTermSetName",
    "ToggleTermToggleAll",
    "ToggleTermSendVisualLines",
    "ToggleTermSendCurrentLine",
    "ToggleTermSendVisualSelection",
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.40
      end
    end,
    on_open = function()
      vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
      vim.api.nvim_set_option_value("foldexpr", "0", { scope = "local" })
    end,
    highlights = {
      Normal = { link = "Normal" },
      NormalFloat = { link = "NormalFloat" },
      FloatBorder = { link = "FloatBorder" },
    },
    open_mapping = false,
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = false,
    shading_factor = "1",
    start_in_insert = true,
    persist_mode = false,
    insert_mappings = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = get_default_shell(),
  },
}
