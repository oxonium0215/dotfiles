return {
  lsp = {
    servers = { "yamlls" },
    setup = {
      yamlls = function()
        local schemas = {}
        local ok, schemastore = pcall(require, "schemastore")
        if ok then
          schemas = schemastore.yaml.schemas()
        end
        return {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = schemas,
            },
          },
        }
      end,
    },
    formatters = { "yamlfmt" },
  },
  indent = {
    shiftwidth = 2,
    tabstop = 2,
    expandtab = true,
  },
  treesitter = { "yaml" },
}
