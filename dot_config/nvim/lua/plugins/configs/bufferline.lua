--dofile(vim.g.base46_cache .. "bufferline")

vim.cmd [[
function! Toggle_theme(a,b,c,d)
    lua require('base46').toggle_theme()
endfunction

function! Quit_vim(a,b,c,d)
    qa
endfunction
]]

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
        modified_icon = "●",
        buffer_close_icon = "󰅖",
        close_command = require("bufdelete").bufdelete,
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
--        diagnostics_indicator = function(_, _, diag)
--            local icons = require('core.icons').get('diagnostics')
--            local ret = (diag.error and icons.Error .. diag.error .. " " or "")
--              .. (diag.warning and icons.Warn .. diag.warning or "")
--            return vim.trim(ret)
--        end,
        custom_areas = {
            right = function()
                return {
                    { text = "%@Toggle_theme@" .. "   " .. "%X" },
                    { text = "%@Quit_vim@󰅖 %X" }
                }
            end,
        }
    }
}

return opts
