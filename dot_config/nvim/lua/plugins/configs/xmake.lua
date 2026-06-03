require("xmake").setup({
  on_save = {
    reload_project_info = true,
    lsp_compile_commands = {
      enable = true,
      output_dir = ".", -- プロジェクトルートに配置して clangd が検出できるようにする
    },
  },
  runner = {
    type = "toggleterm",
    config = {
      toggleterm = {
        direction = "float",
        close_on_success = false,
      },
    },
  },
  execute = {
    type = "toggleterm",
    config = {
      toggleterm = {
        direction = "horizontal",
        close_on_success = true,
      },
    },
  },
})
