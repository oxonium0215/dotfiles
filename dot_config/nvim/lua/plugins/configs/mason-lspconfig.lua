require("mason-lspconfig").setup()

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("mason-lspconfig").setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({ capabilities = capabilities, on_attach = on_attach })
	end,
	["rust_analyzer"] = function()
		local has_rust_tools, rust_tools = pcall(require, "rust-tools")
		if has_rust_tools then
			rust_tools.setup({ server = { capabilities = capabilities, on_attach = on_attach } })
		else
			lspconfig.rust_analyzer.setup({ capabilities = capabilities, on_attach = on_attach })
		end
	end,
	["lua_ls"] = function()
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					hint = { enable = true },
					format = {
						enable = true,
						defaultConfig = {
							indent_style = "tab",
							indent_size = "2",
						}
					},
				},
			},
		})
	end,
})
