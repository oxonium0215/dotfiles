local M = {}

local utils = require("core.utils")
local langs = require("config.lsp.langs")
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

local default_indent_by_ft = {
  -- 2 spaces
  javascript = { width = 2, expandtab = true },
  javascriptreact = { width = 2, expandtab = true },
  typescript = { width = 2, expandtab = true },
  typescriptreact = { width = 2, expandtab = true },
  vue = { width = 2, expandtab = true },
  html = { width = 2, expandtab = true },
  css = { width = 2, expandtab = true },
  scss = { width = 2, expandtab = true },
  json = { width = 2, expandtab = true },
  jsonc = { width = 2, expandtab = true },
  yaml = { width = 2, expandtab = true },
  ["yaml.ansible"] = { width = 2, expandtab = true },
  ["yaml.docker-compose"] = { width = 2, expandtab = true },
  ["yaml.gitlab"] = { width = 2, expandtab = true },
  ["yaml.helm-values"] = { width = 2, expandtab = true },
  toml = { width = 2, expandtab = true },
  lua = { width = 2, expandtab = true },
  typst = { width = 2, expandtab = true },
  r = { width = 2, expandtab = true },
  angular = { width = 2, expandtab = true },
  tex = { width = 2, expandtab = true },
  plaintex = { width = 2, expandtab = true },
  c = { width = 2, expandtab = true },
  cpp = { width = 2, expandtab = true },
  -- 4 spaces
  python = { width = 4, expandtab = true },
  rust = { width = 4, expandtab = true },
  cs = { width = 4, expandtab = true },
  zig = { width = 4, expandtab = true },
  sh = { width = 4, expandtab = true },
  bash = { width = 4, expandtab = true },
  -- Tabs (width 4)
  go = { width = 4, expandtab = false },
  make = { width = 4, expandtab = false },
}

local function detect_clang_format(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if not bufname or bufname == "" then
    return nil
  end
  local dir = vim.fs.dirname(bufname)
  local found = vim.fs.find({ ".clang-format", "_clang-format" }, { path = dir, upward = true })
  if not found or #found == 0 then
    return nil
  end
  local f = io.open(found[1], "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  if not content then
    return nil
  end

  local indent_width = content:match("IndentWidth%s*:%s*(%d+)")
  local use_tab = content:match("UseTab%s*:%s*(%w+)")
  local tab_width = content:match("TabWidth%s*:%s*(%d+)")

  local width = indent_width and tonumber(indent_width) or (tab_width and tonumber(tab_width))
  local expandtab = true
  if use_tab and (use_tab == "Always" or use_tab == "ForIndentation") then
    expandtab = false
  end

  if width and width > 0 then
    return { width = width, expandtab = expandtab }
  end
  return nil
end

local function extract_lsp_indent(client, bufnr)
  if not client then
    return nil
  end

  -- Clangd: detect .clang-format or fallback to clangd's default LLVM style (2 spaces)
  if client.name == "clangd" then
    local clang_cfg = detect_clang_format(bufnr)
    if clang_cfg then
      return clang_cfg
    end
    return { width = 2, expandtab = true }
  end

  if not client.config or not client.config.settings then
    return nil
  end
  local settings = client.config.settings

  -- 1. Lua (lua_ls)
  if settings.Lua and settings.Lua.format and settings.Lua.format.defaultConfig then
    local cfg = settings.Lua.format.defaultConfig
    local size = tonumber(cfg.indent_size)
    local is_space = cfg.indent_style ~= "tab"
    if size and size > 0 then
      return { width = size, expandtab = is_space }
    end
  end

  -- 2. YAML / JSON
  for _, sec in ipairs({ "yaml", "json" }) do
    if settings[sec] and settings[sec].format and settings[sec].format.tabSize then
      local size = tonumber(settings[sec].format.tabSize)
      if size and size > 0 then
        return { width = size, expandtab = true }
      end
    end
  end

  -- 3. Generic server settings patterns
  local client_name = client.name
  if client_name and settings[client_name] and type(settings[client_name]) == "table" then
    local s = settings[client_name]
    local size = s.tabSize or s.indentSize or (s.format and (s.format.tabSize or s.format.indentSize))
    if size and tonumber(size) and tonumber(size) > 0 then
      return { width = tonumber(size), expandtab = true }
    end
  end

  return nil
end

local function apply_buffer_indent(bufnr, client)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local ft = vim.bo[bufnr].filetype
  if not ft or ft == "" then
    return
  end

  -- Respect EditorConfig if it already set indent options for this buffer
  local ec = vim.b[bufnr].editorconfig
  if ec and (ec.indent_size or ec.tab_width) then
    return
  end

  local indent = nil

  -- 1. Extract from active LSP client settings
  if client then
    indent = extract_lsp_indent(client, bufnr)
  end

  -- 1.5 For C/C++, detect .clang-format if present
  if not indent and (ft == "c" or ft == "cpp") then
    indent = detect_clang_format(bufnr)
  end

  -- 2. Extract from config.lsp.languages
  if not indent then
    local matching = langs.matching_configs(ft)
    for _, lang_cfg in pairs(matching) do
      if lang_cfg.indent then
        local w = lang_cfg.indent.shiftwidth or lang_cfg.indent.tabstop or lang_cfg.indent.width
        local exp = lang_cfg.indent.expandtab
        if w then
          indent = { width = w, expandtab = exp ~= false }
          break
        end
      end
    end
  end

  -- 3. Fallback to common language defaults
  if not indent then
    indent = default_indent_by_ft[ft]
  end

  if indent and indent.width then
    vim.bo[bufnr].shiftwidth = indent.width
    vim.bo[bufnr].tabstop = indent.width
    vim.bo[bufnr].softtabstop = indent.width
    if indent.expandtab ~= nil then
      vim.bo[bufnr].expandtab = indent.expandtab
    end
  end
end

M.apply_buffer_indent = apply_buffer_indent

M.on_attach = function(client, bufnr)
  utils.set_mappings("lspconfig", { buffer = bufnr })

  if client:supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
    enable_inlay_hints(bufnr)
  end

  apply_buffer_indent(bufnr, client)
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
    automatic_enable = false,
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

    local ok_native = pcall(vim.lsp.config, server_name, opts)
    local config = ok_native and vim.lsp.config[server_name]

    if not config or not config.filetypes then
      local ok_def, def = pcall(require, "lspconfig.configs." .. server_name)
      if ok_def and def and def.default_config then
        config = vim.tbl_deep_extend("force", {}, def.default_config, opts)
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
          apply_buffer_indent(event.buf)

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

          local function launch(root_dir)
            local cfg = vim.deepcopy(config)
            cfg.on_attach = cfg.on_attach or M.on_attach
            cfg.capabilities = cfg.capabilities or M.capabilities
            cfg.root_dir = root_dir
            cfg.name = cfg.name or server_name
            if cfg.root_dir == nil and cfg.cmd == nil then
              return
            end
            vim.lsp.start(cfg, {
              bufnr = event.buf,
              reuse_client = cfg.reuse_client,
              _root_markers = cfg.root_markers,
            })
          end

          local function start_server()
            if not has_required_runtime() then
              return
            end

            if type(config.root_dir) == "function" then
              local called = false
              local function on_dir(dir)
                if not called then
                  called = true
                  vim.schedule(function()
                    launch(dir)
                  end)
                end
              end

              local nparams = debug.getinfo(config.root_dir, "u").nparams
              if nparams < 2 then
                local bufname = vim.api.nvim_buf_get_name(event.buf)
                local ok, res = pcall(config.root_dir, bufname)
                if ok and type(res) == "string" then
                  on_dir(res)
                end
                return
              end

              -- nparams >= 2: Neovim 0.11+ / 0.12+ (bufnr, on_dir)
              local ok, res = pcall(config.root_dir, event.buf, on_dir)
              if ok and (called or type(res) == "string") then
                if not called and type(res) == "string" then
                  on_dir(res)
                end
                return
              end

              -- Fallback for legacy functions expecting (fname, bufnr)
              local bufname = vim.api.nvim_buf_get_name(event.buf)
              local ok2, res2 = pcall(config.root_dir, bufname, on_dir)
              if ok2 and (called or type(res2) == "string") then
                if not called and type(res2) == "string" then
                  on_dir(res2)
                end
                return
              end
            else
              launch(config.root_dir)
            end
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
