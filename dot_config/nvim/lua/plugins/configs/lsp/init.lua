local M = {}

local utils = require("core.utils")
local langs = require("plugins.configs.lsp.langs")
local runtime_warned = {}

local function smart_format(opts)
  local bufnr = opts and opts.bufnr or vim.api.nvim_get_current_buf()
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.format({ bufnr = bufnr, lsp_format = "fallback" })
    return
  end

  vim.lsp.buf.format({ bufnr = bufnr })
end

M.smart_format = smart_format

local function enable_inlay_hints(bufnr)
  local ih = vim.lsp.inlay_hint
  if type(ih) == "function" then
    ih(bufnr, true)
    return
  end
  if type(ih) == "table" and ih.enable then
    -- Handle both 0.10 (`enable(enable, opts)`) and 0.11 (`enable(bufnr, enable)`) signatures
    local ok = pcall(ih.enable, bufnr, true)
    if not ok then
      pcall(ih.enable, true, { bufnr = bufnr })
    end
  end
end

M.on_attach = function(client, bufnr)
  utils.set_mappings("lspconfig", { buffer = bufnr })

  if client:supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
    enable_inlay_hints(bufnr)
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
  local mlsp_mapping = require("mason-lspconfig.mappings").get_all()
  local lsp_to_package = (mlsp_mapping and mlsp_mapping.lspconfig_to_package) or {}
  local registry = require("mason-registry")
  local exec_requirements = langs.exec_requirements()

  local function resolve_package(server)
    return lsp_to_package[server] or server
  end

  servers = vim.tbl_filter(function(name)
    return lsp_to_package[name] ~= nil
  end, servers)

  mlsp.setup({
    -- ensure_installed = servers, -- Removed for lazy loading
    automatic_installation = false,
  })

  for _, server_name in ipairs(servers) do
    local pkg_name = resolve_package(server_name)
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

          local function has_required_runtime()
            local req = exec_requirements[server_name] or exec_requirements[pkg_name]
            if not req then
              return true
            end
            local ok = vim.fn.executable(req) == 1
            if not ok then
              local key = (pkg_name or server_name or "?") .. "::" .. req
              if not runtime_warned[key] then
                runtime_warned[key] = true
                vim.schedule(function()
                  vim.notify(
                    string.format(
                      "Missing runtime '%s' for %s; skipping start until it is installed.",
                      req,
                      server_name
                    ),
                    vim.log.levels.WARN
                  )
                end)
              end
            end
            return ok
          end

          local function start_server()
            if not has_required_runtime() then
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
          end

          if not has_required_runtime() then
            return
          end

          if not registry.is_installed(pkg_name) then
            require("core.lazy_install").install({ pkg_name }, function(results)
              if results and results[pkg_name] and has_required_runtime() then
                vim.schedule(start_server)
              end
            end)
          else
            start_server()
          end
        end,
      })
    end

    ::continue::
  end
end

local function setup_formatting()
  local ok_conform = pcall(require, "conform")
  if ok_conform then
    return
  end

  local format_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_group,
    callback = function(event)
      if vim.g.autoformat_enabled then
        smart_format({ bufnr = event.buf })
      end
    end,
  })
end

function M.setup()
  setup_servers()
  setup_formatting()
end

return M
