return {
  lsp = {
    servers = { "rust_analyzer" },
    formatters = { "rustfmt" },
    setup = {
      rust_analyzer = function()
        local has_rust_tools, rust_tools = pcall(require, "rust-tools")
        if has_rust_tools then
          rust_tools.setup({
            server = {
              on_attach = require("plugins.configs.lsp").on_attach,
              capabilities = require("plugins.configs.lsp").capabilities
            }
          })
        else
          require("lspconfig").rust_analyzer.setup({
            on_attach = require("plugins.configs.lsp").on_attach,
            capabilities = require("plugins.configs.lsp").capabilities
          })
        end
      end
    }
  },
  treesitter = { "rust" }
}
