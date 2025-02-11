local null_ls = require("null-ls")

return {
  setup = function()
    null_ls.setup({
      sources = {
        -- Default sources will be added automatically
        -- through mason-null-ls integration
      }
    })
  end
}
