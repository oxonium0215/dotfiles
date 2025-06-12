return {
  lsp = {
    servers = { "texlab" },
    formatters = { "latexindent" },
    linters = { "chktex" },
    setup = {
      texlab = function()
        return {
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = {
                  "-lualatex",
                  "-synctex=1",
                  "-interaction=nonstopmode",
                  "-file-line-error",
                  "%f"
                },
                onSave = true,
                forwardSearchAfter = false,  -- Disable to avoid conflicts
              },
              forwardSearch = {
                executable = "SumatraPDF.exe",
                args = {
                  "-reuse-instance",
                  "-inverse-search",
                  "\"nvim --headless -c \\\"VimtexInverseSearch %l '%f'\\\"\"",
                  "%p"
                }
              },
              completion = {
                triggerCharacters = { "\\", "{", "}", "[", "]" }
              },
              diagnostics = {
                allowedPatterns = { ".*" },
                ignoredPatterns = {
                  "^Overfull \\\\hbox.*",
                  "^Underfull \\\\hbox.*",
                  ".*will be scaled.*",
                  ".*luatexja-fontspec Warning.*"
                }
              },
              -- Enhanced Japanese support
              experimental = {
                followPackageLinks = true,
                mathEnvironments = { "align", "equation", "gather" }
              }
            }
          }
        }
      end
    }
  },
  treesitter = { "latex", "bibtex" }
}
