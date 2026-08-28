local M = {}

local langs = require("plugins.configs.lsp.langs")

M.setup = function()
  local formatters_by_ft = {}
  local all_langs = langs.all()

  for lang, config in pairs(all_langs) do
    if config.lsp and config.lsp.formatters and #config.lsp.formatters > 0 then
      local fts = { lang }
      if lang == "c" or lang == "cpp" then
        fts = { "c", "cpp", "objc", "objcpp" }
      elseif lang == "javascript" or lang == "typescript" then
        fts = { lang, lang .. "react" }
      end

      for _, f in ipairs(fts) do
        formatters_by_ft[f] = formatters_by_ft[f] or {}
        for _, fmt in ipairs(config.lsp.formatters) do
          if not vim.tbl_contains(formatters_by_ft[f], fmt) then
            table.insert(formatters_by_ft[f], fmt)
          end
        end
      end
    end
  end

  require("conform").setup({
    formatters_by_ft = formatters_by_ft,
    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 1000,
    },
    format_on_save = function(bufnr)
      if vim.g.autoformat_enabled == false then
        return nil
      end
      return {
        timeout_ms = 1000,
        lsp_format = "fallback",
      }
    end,
  })
end

return M
