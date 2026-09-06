return {
  "m4xshen/hardtime.nvim",
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    disable_mouse = false,
    disabled_filetypes = { "qf", "alpha", "NvimTree", "lazy", "mason", "oil", "toggleterm" },
    max_count = 10,
  },
}
