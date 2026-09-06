return {
  "nvim-tree/nvim-web-devicons",
  enabled = function()
    return not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false"
  end,
}
