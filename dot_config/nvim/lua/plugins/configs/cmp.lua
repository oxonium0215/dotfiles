local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")
local tailwindcss_cmp = require("tailwindcss-colorizer-cmp")
local vscodesnippets = require("luasnip.loaders.from_vscode")

cmp.setup({
    completion = {
        completeopt = "menu,menuone,preview,noselect",
    },

    window = {
        completeion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },

    mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        },
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
            else
                fallback()
            end
        end, {
        "i",
        "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif require("luasnip").jumpable(-1) then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
        else
            fallback()
        end
    end, {
    "i",
    "s",
}),
  },
  sources = {
      {
          name = "lazydev", -- Neovim APIs autocompletions
          group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      },
      { name = "path" },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "luasnip" },
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "emoji" },
      { name = "calc" },
      { name = "treesitter" },
      { name = "rg" },
  },
  formatting = {
      fields = { "abbr", "kind", "menu" },
      format = function(entry, item)
          -- Apply apply lspkind formatter
          item = lspkind.cmp_format({ with_text = true, maxwidth = 50 })(entry, item)
          -- Then apply tailwindcss-colorizer-cmp formatter
          return tailwindcss_cmp.formatter(entry, item)
      end,
  },

})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "cmp_git" },
    }, {
        { name = "buffer" },
    }),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})

--  VS Code like snippets
vscodesnippets.lazy_load()
