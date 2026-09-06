local utils = require("core.utils")

return {
  "akinsho/bufferline.nvim",
  event = { "BufReadPost" },
  keys = utils.generate_lazy_keys("bufferline"),
  opts = {
    options = {
      always_show_bufferline = true,
      offsets = {
        {
          filetype = "NvimTree",
          text = "Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
      modified_icon = "●",
      buffer_close_icon = "󰅖",
      close_command = function(bufnr)
        local ok, bufdelete = pcall(require, "bufdelete")
        if ok then
          bufdelete.bufdelete(bufnr)
        else
          vim.cmd("bdelete " .. bufnr)
        end
      end,
      show_close_icon = false,
      left_trunc_marker = " ",
      right_trunc_marker = " ",
      numbers = "ordinal",
      max_name_length = 20,
      max_prefix_length = 13,
      tab_size = 20,
      show_tab_indicators = true,
      enforce_regular_tabs = false,
      show_buffer_close_icons = true,
      separator_style = "thin",
      themable = true,
      diagnostics = "nvim_lsp",
      diagnostics_update_in_insert = false,
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    local function refresh_bufferline()
      local ok, bufferline = pcall(require, "bufferline")
      if ok then
        bufferline.setup(opts)
      end
    end
    -- session restore fix
    vim.api.nvim_create_autocmd("BufAdd", {
      callback = function()
        vim.schedule(function()
          refresh_bufferline()
        end)
      end,
    })
  end,
}
