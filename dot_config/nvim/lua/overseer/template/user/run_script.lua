return {
  name = "run script",
  builder = function()
    local file = vim.fn.expand("%:p")
    local ft = vim.bo.filetype
    local cmd = { file }

    if ft == "python" then
      if vim.fn.executable("uv") == 1 then
        cmd = { "uv", "run", file }
      elseif vim.fn.executable("python3") == 1 then
        cmd = { "python3", file }
      else
        cmd = { "python", file }
      end
    elseif ft == "go" then
      cmd = { "go", "run", file }
    elseif ft == "rust" then
      if vim.fs.root(0, "Cargo.toml") then
        cmd = { "cargo", "run" }
      else
        local outfile = vim.fn.expand("%:p:r")
        if vim.fn.has("win32") == 1 then
          outfile = outfile .. ".exe"
        end
        cmd = { "rustc", file, "-o", outfile }
      end
    elseif ft == "javascript" or ft == "typescript" then
      if vim.fn.executable("bun") == 1 then
        cmd = { "bun", "run", file }
      elseif vim.fn.executable("deno") == 1 then
        cmd = { "deno", "run", "-A", file }
      elseif vim.fn.executable("node") == 1 then
        cmd = { "node", file }
      end
    elseif ft == "sh" or ft == "bash" or ft == "zsh" then
      cmd = { "bash", file }
    elseif ft == "typst" then
      cmd = { "typst", "compile", file }
    end

    return {
      cmd = cmd,
      components = {
        { "on_output_quickfix", set_diagnostics = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = { "sh", "bash", "zsh", "python", "go", "rust", "javascript", "typescript", "typst" },
  },
}
