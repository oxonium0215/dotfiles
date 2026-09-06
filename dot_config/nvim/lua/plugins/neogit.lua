return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function()
    local ok_diff = pcall(require, "diffview")
    local ok_tel = pcall(require, "telescope")
    return {
      integrations = {
        diffview = ok_diff,
        telescope = ok_tel,
      },
      disable_commit_confirmation = true,
      graph_style = "unicode",
    }
  end,
}
