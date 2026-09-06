return {
  "L3MON4D3/LuaSnip",
  version = "2.*",
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },
  build = (function()
    if jit and jit.os and jit.os:lower() == "windows" then
      return nil
    end
    return "make install_jsregexp"
  end)(),
  config = function()
    local luasnip = require("luasnip")

    luasnip.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
    })

    -- Load vscode snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load({ paths = vim.g.vscode_snippets_path or "" })

    -- Load snipmate snippets
    require("luasnip.loaders.from_snipmate").load()
    require("luasnip.loaders.from_snipmate").lazy_load({ paths = vim.g.snipmate_snippets_path or "" })

    -- Load lua snippets
    require("luasnip.loaders.from_lua").load()
    require("luasnip.loaders.from_lua").lazy_load({ paths = vim.g.lua_snippets_path or "" })

    local unlink_group = vim.api.nvim_create_augroup("LuasnipUnlinkOnLeave", { clear = true })
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = unlink_group,
      callback = function()
        if
          luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
          and not luasnip.session.jump_active
        then
          luasnip.unlink_current()
        end
      end,
    })

    local ok_japanese, japanese = pcall(require, "core.japanese")
    if ok_japanese and japanese.setup_japanese_snippets then
      japanese.setup_japanese_snippets()
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("luasnip-lazy-load", { clear = true }),
      pattern = "*",
      callback = function()
        require("luasnip.loaders.from_vscode").lazy_load({
          paths = vim.api.nvim_get_runtime_file("snippets/" .. vim.bo.filetype, true),
        })
      end,
    })
  end,
}
