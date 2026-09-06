return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  cond = function()
    -- Only load alpha if no files are opened
    return vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "                                                     ",
      "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
      "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
      "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
      "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
      "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
      "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
      "                                                     ",
    }

    dashboard.section.buttons.val = {
      dashboard.button("<leader>n", "󰻭  New File", ":enew | NvimTreeFocus<CR>", { desc = "New file" }),
      dashboard.button("<leader>r", "  Recent Files", ":Telescope oldfiles<CR>", { desc = "Old files" }),
      dashboard.button("<leader>ff", "  Find File", ":Telescope find_files<CR>"),
      dashboard.button("<leader>fg", "󰱽  Find in files", ":Telescope live_grep<CR>"),
    }

    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    local num_plugins_tot = stats.count
    local num_plugins_loaded = stats.loaded
    if num_plugins_tot <= 1 then
      dashboard.section.footer.val =
        { num_plugins_loaded .. " / " .. num_plugins_tot .. " plugin loaded in " .. ms .. "ms" }
    else
      dashboard.section.footer.val =
        { num_plugins_loaded .. " / " .. num_plugins_tot .. " plugins loaded in " .. ms .. "ms" }
    end
    dashboard.section.footer.opts.hl = "Comment"

    local head_butt_padding = 3
    local occu_height = #dashboard.section.header.val + 2 * #dashboard.section.buttons.val + head_butt_padding
    local header_padding = math.max(0, math.ceil((vim.fn.winheight("$") - occu_height) * 0.25))
    local foot_butt_padding_ub = vim.o.lines - header_padding - occu_height - #dashboard.section.footer.val - 3
    local foot_butt_padding = math.floor((vim.fn.winheight("$") - 2 * header_padding - occu_height))
    foot_butt_padding =
      math.max(0, math.max(math.min(0, foot_butt_padding), math.min(math.max(0, foot_butt_padding), foot_butt_padding_ub)))

    dashboard.config.layout = {
      { type = "padding", val = header_padding },
      dashboard.section.header,
      { type = "padding", val = head_butt_padding },
      dashboard.section.buttons,
      { type = "padding", val = foot_butt_padding },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.opts)
  end,
}
