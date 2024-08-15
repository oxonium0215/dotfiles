local opts = {
    animation = true,
    auto_hide = false,
    tabpages = true,
    clickable = true,
    icons = {
        buffer_index = true,
        buffer_number = false,
        button = '',
        filetype = {
            enabled = true,
        },
        separator = { left = '▎', right = '' },
        modified = { button = '●' },
        inactive = {
            separator = { left = '', right = '' },
        },
    },
    maximum_length = 30,
    maximum_padding = 1,
    semantic_letters = true,
    letters = 'abcdefghijklmnopqrstuvwxyz',
    no_name_title = nil,
    sidebar_filetypes = {
        NvimTree = true,
    }
}

return opts
