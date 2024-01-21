require("copilot").setup({
	suggestion = {
		auto_trigger = true,
		keymap = {
			accept = "<C-Y>",
			accept_word = false,
			accept_line = false,
			next = "<C-N>",
			prev = "<C-P>",
			dismiss = "<C-J>",
		},
	},
})

vim.api.nvim_command("highlight link CopilotAnnotation LineNr")
vim.api.nvim_command("highlight link CopilotSuggestion LineNr")

vim.keymap.set("i", "<C-E>", function()
	require("cmp").mapping.abort()
	require("copilot.suggestion").accept()
end, {
	desc = "[copilot] accept suggestion",
	silent = true,
})
