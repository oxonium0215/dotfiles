local M = {}

local langs = require("plugins.configs.lsp.langs")

M.setup = function()
  local lint = require("lint")
  local linters_by_ft = {}
  local all_langs = langs.all()

  for lang, config in pairs(all_langs) do
    if config.lsp and config.lsp.linters and #config.lsp.linters > 0 then
      local fts = { lang }
      if lang == "c" or lang == "cpp" then
        fts = { "c", "cpp" }
      elseif lang == "javascript" or lang == "typescript" then
        fts = { lang, lang .. "react" }
      end

      for _, f in ipairs(fts) do
        linters_by_ft[f] = linters_by_ft[f] or {}
        for _, ltr in ipairs(config.lsp.linters) do
          if not vim.tbl_contains(linters_by_ft[f], ltr) then
            table.insert(linters_by_ft[f], ltr)
          end
        end
      end
    end
  end

  lint.linters_by_ft = linters_by_ft

  local lint_augroup = vim.api.nvim_create_augroup("NvimLint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
      if vim.bo.buftype == "" then
        lint.try_lint()
      end
    end,
  })
end

return M
