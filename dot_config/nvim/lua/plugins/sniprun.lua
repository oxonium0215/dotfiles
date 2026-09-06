return {
  "michaelb/sniprun",
  branch = "master",
  build = "sh install.sh",
  enabled = function()
    return vim.fn.has("win32") == 0
  end,
  opts = {
    display = { "Terminal", "NvimNotifyErr" },
    display_options = {
      terminal_scrollback = vim.o.scrollback,
      terminal_line_number = false,
      terminal_signcolumn = false,
      terminal_width = 35,
    },
    inline_messages = 0,
    borders = "single",
  },
}
