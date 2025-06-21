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
                                    "-lualatex",  -- Use LuaLaTeX engine
                                    "-synctex=1",
                                    "-interaction=nonstopmode",
                                    "-file-line-error",
                                    "%f"
                                },
                                onSave = true,
                                forwardSearchAfter = false,
                            },
                            forwardSearch = {
                                executable = vim.fn.has('win32') == 1 and "SumatraPDF.exe" or
                                vim.fn.has('mac') == 1 and "open" or "zathura",
                                args = vim.fn.has('win32') == 1 and {
                                    "-reuse-instance",
                                    "-inverse-search",
                                    "\"nvim --headless -c \\\"VimtexInverseSearch %l '%f'\\\"\"",
                                    "%p"
                                } or vim.fn.has('mac') == 1 and {
                                    "-a", "Skim.app",
                                    "%p"
                                } or {
                                    "--synctex-forward", "%l:1:%f",
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
                                    ".*fontspec Warning.*",
                                    ".*luatexja Warning.*",
                                    ".*luaotfload.*WARNING.*"
                                }
                            },
                            -- Enhanced LuaLaTeX support
                            experimental = {
                                followPackageLinks = true,
                                mathEnvironments = { "align", "equation", "gather" },
                                verbatimEnvironments = { "luacode", "luacode*" }
                            }
                        }
                    }
                }
            end
        }
    },
    treesitter = { "latex", "bibtex", "lua" }  -- Added Lua for LuaLaTeX code blocks
}
