return {
  "mason-org/mason.nvim",
  cmd = "Mason",
  opts = {
    ui = {
      icons = {
        package_pending = " ",
        package_installed = "󰄳 ",
        package_uninstalled = " 󰚌",
      },
      keymaps = {
        toggle_server_expand = "<CR>",
        install_server = "i",
        update_server = "u",
        check_server_version = "c",
        update_all_servers = "U",
        check_outdated_servers = "C",
        uninstall_server = "X",
        cancel_installation = "<C-c>",
      },
    },
    max_concurrent_installers = 10,
    PATH = "skip",
  },
  config = function(_, opts)
    require("mason").setup(opts)
    vim.g.mason_binaries_list = opts.ensure_installed
  end,
}
