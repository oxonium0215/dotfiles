return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  config = function()
    vim.defer_fn(function()
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
        local ok_cmp, cmp = pcall(require, "cmp")
        if ok_cmp then
          cmp.abort()
        end
        require("copilot.suggestion").accept()
      end, {
        desc = "[copilot] accept suggestion",
        silent = true,
      })
    end, 100)
  end,
}
