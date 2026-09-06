return {
  lsp = {
    servers = { "lua_ls" },
    formatters = { "stylua" },
    setup = {
      lua_ls = function()
        return {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = {
                library = {
                  vim.fn.expand("$VIMRUNTIME/lua"),
                  vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                  vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                  "${3rd}/luv/library",
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
              },
              hint = { enable = true },
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "4",
                },
              },
            },
          },
        }
      end,
    },
  },
  treesitter = { "lua" },
}
