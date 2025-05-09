local M = {}
local utils = require("core.utils")

M.on_attach = function(client, bufnr)
  local filetype = vim.bo[bufnr].filetype
  local null_ls_sources = require("null-ls.sources")
  local has_formatters = #null_ls_sources.get_available(filetype, "formatting") > 0

  -- Only disable LSP formatting if null-ls formatters are available
  if client.name ~= "null-ls" and has_formatters then
    -- Update to use the new API name in Neovim 0.11+
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end

  utils.set_mappings("lspconfig", { buffer = bufnr })

  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end
  })
end

M.capabilities = require("cmp_nvim_lsp").default_capabilities()
M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

function M.setup()
  local lang_configs = {}
  local config_path = vim.fn.stdpath("config") .. "/lua/plugins/configs/lsp/languages"

  -- Load all language configurations
  for _, file in ipairs(vim.fn.globpath(config_path, "*.lua", false, true)) do
    local lang = file:match(".*/(.*)%.lua$")
    if lang then
      local ok, config = pcall(require, "plugins.configs.lsp.languages." .. lang)
      if ok then lang_configs[lang] = config end
    end
  end

  local mason_registry = require("mason-registry")
  local lspconfig = require("lspconfig")
  local ts_parsers = require("nvim-treesitter.parsers")
  local pending = { lsp = {}, ts = {}, null_ls = {} }
  local null_ls = require("null-ls")
  null_ls.setup()

  -- Configure diagnostics
  vim.diagnostic.config({
    virtual_text = { prefix = "●" },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded" },
  })

  -- Create server setup map
  -- This will be used to apply custom configurations to servers
  local server_setups = {}
  for _, lang_config in pairs(lang_configs) do
    if lang_config.lsp and lang_config.lsp.setup then
      for server, setup_func in pairs(lang_config.lsp.setup) do
        server_setups[server] = setup_func
      end
    end
  end

  -- Apply server configurations using the new vim.lsp.config API for servers that support it
  -- For other servers, use the traditional lspconfig approach
  local apply_server_config = function(server_name)
    local base_config = {
      on_attach = M.on_attach,
      capabilities = M.capabilities,
    }

    if server_setups[server_name] then
      local custom_config = server_setups[server_name]() or {}
      base_config = vim.tbl_deep_extend("force", base_config, custom_config)
    end
    
    -- Try using vim.lsp.config if available (Neovim 0.11+)
    local has_native_config = pcall(function()
      vim.lsp.config(server_name, base_config)
    end)
    
    -- If native config isn't available, fall back to the traditional approach
    if not has_native_config then
      lspconfig[server_name].setup(base_config)
    end
  end

  -- Setup mason-lspconfig with the new API
  require("mason-lspconfig").setup({
    -- Don't use automatic_installation as it's been removed in v2.0.0
    -- Use automatic_enable instead which is enabled by default
    -- automatic_enable = true, -- This is enabled by default
  })

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("AutoInstallLSP", { clear = true }),
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      local config = lang_configs[ft]
      if not config then return end

      -- LSP installation logic
      if config.lsp and config.lsp.servers then
        for _, lsp_name in ipairs(config.lsp.servers) do
          -- Use mappings provided by mason-registry instead of hardcoded values
          -- This replaces the previous approach of using server_mappings.lspconfig_to_package
          local mason_package = require("mason-lspconfig").get_mappings().lspconfig_to_package[lsp_name] or lsp_name

          if not mason_registry.is_installed(mason_package) and not pending.lsp[mason_package] then
            pending.lsp[mason_package] = true
            vim.notify("Installing LSP: " .. mason_package, vim.log.levels.INFO)

            local ok, pkg = pcall(mason_registry.get_package, mason_package)
            if ok then
              pkg:install():once("closed", function()
                pending.lsp[mason_package] = nil
                vim.notify("LSP installed: " .. mason_package, vim.log.levels.INFO)

                vim.schedule(function()
                  -- Apply server configuration directly
                  apply_server_config(lsp_name)
                  vim.cmd("edit " .. vim.fn.expand("%"))
                end)
              end)
            else
              pending.lsp[mason_package] = nil
              vim.notify("Package not found in Mason registry: " .. mason_package, vim.log.levels.ERROR)
            end
          end
        end
      end

      -- Treesitter parser installation (unchanged as this wasn't affected by the breaking changes)
      local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

      for _, parser in ipairs(config.treesitter) do
        if not parser_configs[parser] then
          vim.notify("No parser configuration found for: " .. parser, vim.log.levels.ERROR)
        elseif not ts_parsers.has_parser(parser) and not pending.ts[parser] then
          pending.ts[parser] = true
          vim.notify("Installing parser: " .. parser, vim.log.levels.INFO)
          vim.cmd("TSInstall " .. parser)

          local function check_parser()
            if ts_parsers.has_parser(parser) then
              pending.ts[parser] = nil
              local bufs = vim.api.nvim_list_bufs()
              for _, buf in ipairs(bufs) do
                  if vim.bo[buf].filetype == ft then
                      vim.cmd("e!")
                  end
              end
              vim.notify("Parser activated: " .. parser, vim.log.levels.INFO)
            else
              vim.defer_fn(check_parser, 500)
            end
          end
          vim.defer_fn(check_parser, 500)
        end
      end

      -- null-ls source installation (unchanged)
      if config.lsp then
        local null_ls_sources = {}
        if config.lsp.formatters then
          vim.list_extend(null_ls_sources, config.lsp.formatters)
        end
        if config.lsp.linters then
          vim.list_extend(null_ls_sources, config.lsp.linters)
        end

        for _, source in ipairs(null_ls_sources) do
          if not mason_registry.is_installed(source) and not pending.null_ls[source] then
            pending.null_ls[source] = true
            vim.notify("Installing null-ls source: " .. source, vim.log.levels.INFO)

            local ok, pkg = pcall(mason_registry.get_package, source)
            if ok then
              pkg:install():once("closed", function()
                pending.null_ls[source] = nil
                vim.notify("null-ls source installed: " .. source, vim.log.levels.INFO)
              end)
            else
              pending.null_ls[source] = nil
              vim.notify("Package not found in Mason registry: " .. source, vim.log.levels.ERROR)
            end
          end
        end
      end
    end
  })

  -- Smart formatting command (unchanged)
  function _G.smart_format()
    local filetype = vim.bo.filetype
    local null_formatters = require("null-ls.sources").get_available(filetype, "formatting")

    if #null_formatters > 0 then
      vim.lsp.buf.format({ async = true, filter = function(c) return c.name == "null-ls" end })
    else
      vim.lsp.buf.format({ async = true })
    end
  end

  -- Format-on-save automation (unchanged)
  vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
      if vim.g.autoformat_enabled == true then
        vim.schedule(_G.smart_format)
      end
    end
  })
end

return M
