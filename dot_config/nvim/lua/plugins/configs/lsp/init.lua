local M = {}

local utils = require("core.utils")
local langs = require("plugins.configs.lsp.langs")

local function smart_format(opts)
  local bufnr = opts and opts.bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local ok, sources = pcall(require, "null-ls.sources")
  local has_null_ls = ok and #sources.get_available(ft, "formatting") > 0

  local format_opts = {
    bufnr = bufnr,
    async = false,
  }

  if has_null_ls then
    format_opts.filter = function(client)
      return client.name == "null-ls"
    end
  end

  vim.lsp.buf.format(format_opts)
end

M.smart_format = smart_format

local function enable_inlay_hints(bufnr)
  if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

local function has_null_ls_formatter(bufnr)
  local ok, sources = pcall(require, "null-ls.sources")
  if not ok then
    return false
  end
  return #sources.get_available(vim.bo[bufnr].filetype, "formatting") > 0
end

local function has_formatter(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" })
  return clients and #clients > 0
end

M.on_attach = function(client, bufnr)
  utils.set_mappings("lspconfig", { buffer = bufnr })

  if client.supports_method("textDocument/inlayHint") then
    enable_inlay_hints(bufnr)
  end

  if client.name ~= "null-ls" and has_null_ls_formatter(bufnr) then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
M.capabilities = capabilities

local function setup_servers()
  local server_setups = langs.server_setups()
  local servers = langs.collect_servers()
  local mlsp = require("mason-lspconfig")
  local mapping = require("mason-lspconfig.mappings").get_all().lspconfig_to_package or {}
  servers = vim.tbl_filter(function(name)
    return mapping[name] ~= nil
  end, servers)

  mlsp.setup({
    ensure_installed = servers,
    automatic_installation = false,
  })

  for _, server_name in ipairs(servers) do
    local opts = {
      on_attach = M.on_attach,
      capabilities = M.capabilities,
    }

    if server_setups[server_name] then
      opts = vim.tbl_deep_extend("force", opts, server_setups[server_name]() or {})
    end

    if server_name == "rust_analyzer" then
      local ok_rt, rust_tools = pcall(require, "rust-tools")
      if ok_rt then
        rust_tools.setup({ server = opts })
        goto continue
      end
    end

    local ok_native, config = pcall(vim.lsp.config, server_name, opts)

    if not ok_native then
      local ok_lspc, lspconfig = pcall(require, "lspconfig")
      if ok_lspc and lspconfig[server_name] and lspconfig[server_name].document_config then
        config = vim.tbl_deep_extend("force", {}, lspconfig[server_name].document_config.default_config or {}, opts)
      else
        config = opts
      end
    end

    if config and config.filetypes and #config.filetypes > 0 then
      local group = vim.api.nvim_create_augroup("LspNative_" .. server_name, { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = config.filetypes,
        callback = function(event)
          if #vim.lsp.get_clients({ bufnr = event.buf, name = server_name }) > 0 then
            return
          end
          local cfg = vim.deepcopy(config)
          cfg.on_attach = cfg.on_attach or M.on_attach
          cfg.capabilities = cfg.capabilities or M.capabilities
          if type(cfg.root_dir) == "function" then
            cfg.root_dir = cfg.root_dir(vim.api.nvim_buf_get_name(event.buf))
          end
          cfg.name = cfg.name or server_name
          if cfg.root_dir == nil and cfg.cmd == nil then
            return
          end
          vim.lsp.start(cfg, { bufnr = event.buf })
        end,
      })
    end

    ::continue::
  end
end

local function setup_formatting()
  local format_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_group,
    callback = function(event)
      if vim.g.autoformat_enabled and has_formatter(event.buf) then
        smart_format({ bufnr = event.buf })
      end
    end,
  })
end

function M.setup()
  require("neoconf").setup(require("plugins.configs.neoconf"))
  setup_servers()
  setup_formatting()
end

M.null_ls_ensure = langs.collect_null_ls_sources()
M.treesitter_parsers = langs.collect_parsers()

return M
