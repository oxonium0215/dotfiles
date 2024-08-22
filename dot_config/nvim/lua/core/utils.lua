local M = {}
local merge_tb = vim.tbl_deep_extend

M.echo = function(str)
    vim.cmd "redraw"
    vim.api.nvim_echo({ { str, "Bold" } }, true, {})
end

local function shell_call(args)
    local output = vim.fn.system(args)
    assert(vim.v.shell_error == 0, "External call failed with error code: " .. vim.v.shell_error .. "\n" .. output)
end

M.load_config = function()
    local config = require "core.default_config"
    return config
end

M.set_mappings = function(section, extra_opts)
    local mappings = require("mappings")[section]

    if not mappings then
        error("Invalid mappings section: " .. tostring(section))
    end

    for _, mapping in ipairs(mappings) do
        local mode, lhs, rhs, opts = unpack(mapping)
        if extra_opts then
            opts = vim.tbl_deep_extend("force", opts or {}, extra_opts)
        end
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

M.generate_lazy_keys = function(section)
  local mappings = require("mappings")[section]

  if not mappings then
      error("Invalid mappings section: " .. tostring(section))
  end

  local lazy_keys = {}
  for _, mapping in ipairs(mappings) do
    local mode = mapping[1]
    local lhs = mapping[2]
    local rhs = mapping[3]
    local opts = mapping[4] or {}

    if type(mode) == "table" then
      mode = table.concat(mode, "")
    end

    if type(rhs) == "function" then
      rhs = function() rhs() end
    end

    local lazy_key = {
      lhs,
      rhs,
      mode = mode,
    }

    for key, value in pairs(opts) do
      lazy_key[key] = value
    end

    table.insert(lazy_keys, lazy_key)
  end

  return lazy_keys
end

M.lazy = function(install_path)
    --------- lazy.nvim ---------------
    M.echo "  Installing lazy.nvim & plugins ..."
    local repo = "https://github.com/folke/lazy.nvim.git"
    shell_call { "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }
    vim.opt.rtp:prepend(install_path)

    -- install plugins
    require("plugins")
    M.echo "Setup finished!"
end

M.lazy_load = function(plugin)
    vim.api.nvim_create_autocmd({ "BufRead", "BufWinEnter", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("BeLazyOnFileOpen" .. plugin, {}),
        callback = function()
            local file = vim.fn.expand "%"
            local condition = file ~= "NvimTree_1" and file ~= "[lazy]" and file ~= ""

            if condition then
                vim.api.nvim_del_augroup_by_name("BeLazyOnFileOpen" .. plugin)

                if plugin ~= "nvim-treesitter" then
                    vim.schedule(function()
                        require("lazy").load { plugins = plugin }

                        if plugin == "nvim-lspconfig" then
                            vim.cmd "silent! do FileType"
                        end
                    end, 0)
                else
                    require("lazy").load { plugins = plugin }
                end
            end
        end
    })
end

-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
M.safe_keymap_set = function(mode, lhs, rhs, opts)
    local keys = require("lazy.core.handler").handlers.keys
    ---@cast keys LazyKeysHandler
    local modes = type(mode) == "string" and { mode } or mode

    ---@param m string
    modes = vim.tbl_filter(function(m)
        return not (keys.have and keys:have(lhs, m))
    end, modes)

    -- do not create the keymap if a lazy keys handler exists
    if #modes > 0 then
        opts = opts or {}
        opts.silent = opts.silent ~= false
        if opts.remap and not vim.g.vscode then
            ---@diagnostic disable-next-line: no-unknown
            opts.remap = nil
        end
        vim.keymap.set(modes, lhs, rhs, opts)
    end
end

M.toggleTerm = function(direction)
    local command = ":ToggleTerm direction=" .. direction
    vim.cmd(command)
end

return M
