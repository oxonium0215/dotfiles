local opts = {
    chunk = {
        enable = true,
        chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
        },
        style = {
            { fg = "#806d9c" },
            { fg = "#f35336" },
        },
        textobject = "ic",
        delay = 0,
    },
    indent = {
        enable = true,
        notify = true,
        chars = {
            "│",
        },
        delay = 0,
    },
    line_num = {
        enable = false,
    },
    blank = {
        enable = false,
        chars = {
            "·",
        },
        style = {
            { bg = "#434437" },
            { bg = "#2f4440" },
            { bg = "#433054" },
            { bg = "#284251" },
        },
    }
}

return opts
