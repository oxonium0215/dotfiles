return {
  lsp = {
    servers = { "texlab" },
    formatters = { "latexindent" },
    setup = {
      texlab = function()
        return {
          settings = {
            texlab = {
              -- Build and forward search are now handled by vimtex for better integration.
              -- This ensures a single, reliable system for compilation and viewing.
              completion = {
                triggerCharacters = { "\\", "{", "}", "[", "]" },
              },
              diagnostics = {
                ignoredPatterns = {
                  "^Overfull \\\\hbox.*",
                  "^Underfull \\\\hbox.*",
                  ".*will be scaled.*",
                  ".*fontspec Warning.*",
                  ".*luatexja Warning.*",
                  ".*luaotfload.*WARNING.*",
                },
              },
              experimental = {
                followPackageLinks = true,
                mathEnvironments = { "align", "equation", "gather" },
                verbatimEnvironments = { "luacode", "luacode*" },
              },
            },
          },
        }
      end,
    },
  },
  treesitter = { "latex", "bibtex", "lua" },
}
