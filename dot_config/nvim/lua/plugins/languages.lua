-- Language-specific plugins

return {
    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ LaTeX                                                                           │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "lervag/vimtex",
        ft = { "tex", "bib" },
        keys = require("core.utils").generate_lazy_keys("vimtex"),
        config = function()
            require("plugins.configs.vimtex")
        end,
    },
    {
        "micangl/cmp-vimtex",
        ft = "tex",
        dependencies = { "hrsh7th/nvim-cmp", "lervag/vimtex" },
    },

    -- ╭─────────────────────────────────────────────────────────────────────────────────╮
    -- │ Web Development                                                                 │
    -- ╰─────────────────────────────────────────────────────────────────────────────────╯
    {
        "turbio/bracey.vim",
        cmd = { "Bracey", "BraceyReload", "BraceyEval" },
    },
}