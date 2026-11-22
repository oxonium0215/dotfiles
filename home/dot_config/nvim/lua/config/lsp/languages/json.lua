return {
  lsp = {
    servers = { "jsonls" },
    setup = {
      jsonls = function()
        local schemas = {}
        local ok, schemastore = pcall(require, "schemastore")
        if ok then
          schemas = schemastore.json.schemas()
        end
        return {
          settings = {
            json = {
              schemas = schemas,
              validate = { enable = true },
            },
          },
        }
      end,
    },
    formatters = { "fixjson" },
  },
  indent = {
    shiftwidth = 2,
    tabstop = 2,
    expandtab = true,
  },
  treesitter = { "json" },
}
