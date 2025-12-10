local langs = require("plugins.configs.lsp.langs")

local ts = require("nvim-treesitter")
local ts_config = require("nvim-treesitter.config")

local managed = ts_config.norm_languages(
  vim.list_extend({ "vim", "vimdoc", "query" }, langs.collect_parsers()),
  { unsupported = true }
)

local managed_set = {}
for _, lang in ipairs(managed) do
  managed_set[lang] = true
end

local function installed_set()
  local set = {}
  for _, lang in ipairs(ts_config.get_installed("parsers")) do
    set[lang] = true
  end
  return set
end

local installed = installed_set()
local installs_in_progress = {}
local failed_installs = {}
local pending_buffers = {}

local function maybe_attach_rainbow(bufnr, lang)
  local ok, lib = pcall(require, "rainbow-delimiters.lib")
  if not ok then
    return
  end

  local current_lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
  if current_lang and current_lang == lang then
    pcall(lib.attach, bufnr)
  end
end

local function queue_buffer(lang, bufnr)
  if not (lang and bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
    return
  end
  pending_buffers[lang] = pending_buffers[lang] or {}
  pending_buffers[lang][bufnr] = true
end

local function enable_for_buffer(bufnr, lang)
  if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
    return
  end

  local current_lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
  if not current_lang or current_lang ~= lang then
    return
  end

  local ok = pcall(vim.treesitter.start, bufnr, lang)
  if ok then
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    maybe_attach_rainbow(bufnr, lang)
  end
end

local function ensure_parser(lang, bufnr)
  if not lang then
    return
  end

  if installed[lang] then
    enable_for_buffer(bufnr, lang)
    return
  end

  if not managed_set[lang] then
    return
  end

  queue_buffer(lang, bufnr)

  local task = installs_in_progress[lang]
  if not task then
    local ok
    ok, task = pcall(ts.install, { lang })
    if not ok then
      pending_buffers[lang] = nil
      vim.schedule(function()
        vim.notify(string.format("nvim-treesitter: failed to install parser '%s': %s", lang, task), vim.log.levels.WARN)
      end)
      return
    end
    installs_in_progress[lang] = task
  end

  task:await(function(err, success)
    installs_in_progress[lang] = nil
    local buffers = pending_buffers[lang]
    pending_buffers[lang] = nil

    if err or not success then
      if not failed_installs[lang] then
        failed_installs[lang] = true
        vim.schedule(function()
          vim.notify(string.format("nvim-treesitter: parser install failed for '%s'", lang), vim.log.levels.WARN)
        end)
      end
      return
    end

    installed = installed_set()
    failed_installs[lang] = nil
    vim.schedule(function()
      if buffers then
        for buf in pairs(buffers) do
          enable_for_buffer(buf, lang)
        end
      end
    end)
  end)
end

local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("TreesitterMainBranch", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(event)
      installed = installed_set()
      local lang = vim.treesitter.language.get_lang(event.match)
      ensure_parser(lang, event.buf)
    end,
  })
end

return M
