local lualine = require("lualine")

-- Color table for highlights
-- stylua: ignore
local colors = {
    bg = "#202328",
    fg = "#f8f8f2",
    grey = "#565f89",
    green = "#9ece6a",
    yellow = "#e0af68",
    blue = "#7aa2f7",
    magenta = "#bb9af7",
    red = "#f7768e",
    cyan = "#7dcfff",
    orange = "#ff9e64"
}
local copilot_colors = {
    [""] = {fg = colors.grey, bg = colors.bg},
    ["Normal"] = {fg = colors.grey, bg = colors.bg},
    ["Warning"] = {fg = colors.red, bg = colors.bg},
    ["InProgress"] = {fg = colors.yellow, bg = colors.bg}
}
local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand("%:p:h")
        local gitdir = vim.fn.finddir(".git", filepath .. ";")
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end
}

-- Config
local config = {
    options = {
        component_separators = {left = " ", right = " "},
--        theme = {
--            normal = {
--                a = {fg = colors.blue, bg = colors.bg},
--                b = {fg = colors.cyan, bg = colors.bg},
--                c = {fg = colors.fg, bg = colors.bg},
--                x = {fg = colors.fg, bg = colors.bg},
--                y = {fg = colors.magenta, bg = colors.bg},
--                z = {fg = colors.grey, bg = colors.bg}
--            },
--            insert = {
--                a = {fg = colors.green, bg = colors.bg},
--                z = {fg = colors.grey, bg = colors.bg}
--            },
--            visual = {
--                a = {fg = colors.magenta, bg = colors.bg},
--                z = {fg = colors.grey, bg = colors.bg}
--            },
--            terminal = {
--                a = {fg = colors.orange, bg = colors.bg},
--                z = {fg = colors.grey, bg = colors.bg}
--            }
--        },
		  theme = 'auto',
        globalstatus = true,
        disabled_filetypes = {statusline = {"dashboard", "alpha"}}
    },
    sections = {
        lualine_a = {{"mode", icon = ""}},
        lualine_b = {{"branch", icon = ""}},
        lualine_c = {
            {"filetype", icon_only = true, separator = "", padding = {left = 1, right = 0}},
            {
                "filename",
                symbols = {modified = "  ", readonly = "", unnamed = ""}
            },
            {
                function()
                    return require("nvim-navic").get_location()
                end,
                cond = function()
                    return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
                end,
                color = {fg = colors.grey, bg = colors.bg}
            },
            {
                "diagnostics",
                sources = {"nvim_diagnostic"},
                symbols = {error = " ", warn = " ", info = " "},
                diagnostics_color = {
                    color_error = {fg = colors.red},
                    color_warn = {fg = colors.yellow},
                    color_info = {fg = colors.cyan}
                }
            },
            {
                -- filesize component
                "filesize",
                cond = conditions.buffer_not_empty
            },
            {"%="},
            {
                function()
                    local msg = "No Active Lsp"
                    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
                    local clients = vim.lsp.get_clients()
                    if next(clients) == nil then
                        return msg
                    end
                    for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                        end
                    end
                    return msg
                end,
                icon = " LSP:",
                color = {fg = "#ffffff", gui = "bold"}
            }
        },
        lualine_x = {
            {
                require("lazy.status").updates,
                cond = require("lazy.status").has_updates,
                color = {fg = colors.green}
            },
            {
                function()
                    local icon = " "
                    local status = require("copilot.api").status.data
                    return icon .. (status.message or "")
                end,
                cond = function()
                    local ok, clients = pcall(vim.lsp.get_clients, {name = "copilot", bufnr = 0})
                    return ok and #clients > 0
                end,
                color = function()
                    if not package.loaded["copilot"] then
                        return
                    end
                    local status = require("copilot.api").status.data
                    return copilot_colors[status.status] or copilot_colors[""]
                end
            },
            {
                "diff",
                -- Is it me or the symbol for modified us really weird
                symbols = {added = " ", modified = "󰝤 ", removed = " "},
                diff_color = {
                    added = {fg = colors.green},
                    modified = {fg = colors.orange},
                    removed = {fg = colors.red}
                },
                cond = conditions.hide_in_width
            }
        },
        lualine_y = {
            {
                "o:encoding", -- option component same as &encoding in viml
                fmt = string.upper, -- I'm not sure why it's upper case either ;)
                cond = conditions.hide_in_width,
                color = {fg = colors.green, gui = "bold"}
            },
            {
                "fileformat",
                fmt = string.upper,
                icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
                color = {fg = colors.green, gui = "bold"}
            },
            {
                "branch",
                icon = "",
                color = {fg = colors.violet, gui = "bold"}
            },
            {
                "progress"
            },
            {
                "location",
                color = {fg = colors.cyan, bg = colors.bg}
            }
        },
        lualine_z = {
            function()
                return "  " .. os.date("%X") .. " 📎"
            end
        }
    }
}
lualine.setup(config)
