local opts = {
    options = {
        always_show_bufferline = true,
        offsets = {
            {
                filetype = "NvimTree",
                text = "Explorer",
                highlight = "Directory",
                text_align = "left"
            }
        },
--        indicator_icon = "▎",
--        modified_icon = "●",
--        buffer_close_icon = "",
--        close_icon = "",
--        left_trunc_marker = "",
--        right_trunc_marker = "",
        numbers = "ordinal",
--        max_name_length = 15,
--        max_prefix_length = 6,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
            local icons = require('core.icons').get('diagnostics')
            local ret = (diag.error and icons.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.Warn .. diag.warning or "")
            return vim.trim(ret)
        end,
    }
}

return opts
