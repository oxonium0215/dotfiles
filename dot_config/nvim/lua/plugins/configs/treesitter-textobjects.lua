local M = {}

function M.setup()
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
end

return M
