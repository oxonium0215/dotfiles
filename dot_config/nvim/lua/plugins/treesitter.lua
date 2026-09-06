return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSInstall", "TSUpdate", "TSInstallSync", "TSUpdateSync", "TSUninstall", "TSModuleInfo" },
    build = ":TSUpdate",
    dependencies = {
      { "JoosepAlviste/nvim-ts-context-commentstring", event = "VeryLazy", opts = { enable_autocmd = false } },
    },
    config = function()
      local ok_langs, langs = pcall(require, "config.lsp.langs")
      local parser_list = ok_langs and langs.collect_parsers() or {}

      local ts = require("nvim-treesitter")
      local ts_config = require("nvim-treesitter.config")

      local managed = ts_config.norm_languages(
        vim.list_extend({ "vim", "vimdoc", "query" }, parser_list),
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

      local group = vim.api.nvim_create_augroup("TreesitterMainBranch", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(event)
          installed = installed_set()
          local lang = vim.treesitter.language.get_lang(event.match)
          ensure_parser(lang, event.buf)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
      if not ok then
        return
      end

      textobjects.setup({
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select outer part of a method/function" },
            ["if"] = { query = "@function.inner", desc = "Select inner part of a method/function" },
            ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
            ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
            ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
            ["ab"] = { query = "@block.outer", desc = "Select outer part of a block" },
            ["ib"] = { query = "@block.inner", desc = "Select inner part of a block" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = { query = "@function.outer", desc = "Next method start" },
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
            ["]a"] = { query = "@parameter.inner", desc = "Next argument" },
          },
          goto_next_end = {
            ["]M"] = { query = "@function.outer", desc = "Next method end" },
            ["]["] = { query = "@class.outer", desc = "Next class end" },
          },
          goto_previous_start = {
            ["[m"] = { query = "@function.outer", desc = "Previous method start" },
            ["[["] = { query = "@class.outer", desc = "Previous class start" },
            ["[a"] = { query = "@parameter.inner", desc = "Previous argument" },
          },
          goto_previous_end = {
            ["[M"] = { query = "@function.outer", desc = "Previous method end" },
            ["[]"] = { query = "@class.outer", desc = "Previous class end" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>na"] = { query = "@parameter.inner", desc = "Swap next argument" },
          },
          swap_previous = {
            ["<leader>pa"] = { query = "@parameter.inner", desc = "Swap previous argument" },
          },
        },
      })
    end,
  },
}
