return {
  generator = function(opts, cb)
    local file = vim.fn.expand("%:p")
    local outfile = vim.fn.expand("%:p:r")
    if vim.fn.has("win32") == 1 then
      outfile = outfile .. ".exe"
    end

    local templates = {
      {
        name = "g++ build (Release: -O2)",
        builder = function()
          return {
            cmd = { "g++" },
            args = { "-O2", "-std=c++20", "-Wall", "-Wextra", file, "-o", outfile },
            components = { { "on_output_quickfix", open = true }, "default" },
          }
        end,
        priority = 50,
      },
      {
        name = "g++ build (Debug: -g)",
        builder = function()
          return {
            cmd = { "g++" },
            args = { "-g", "-std=c++20", "-Wall", "-Wextra", file, "-o", outfile },
            components = { { "on_output_quickfix", open = true }, "default" },
          }
        end,
        priority = 51,
      },
      {
        name = "g++ build & run",
        builder = function()
          return {
            cmd = { "g++" },
            args = { "-O2", "-std=c++20", "-Wall", "-Wextra", file, "-o", outfile },
            components = {
              { "on_output_quickfix", open = true },
              { "on_complete_run", template = { cmd = { outfile } } },
              "default",
            },
          }
        end,
        priority = 49,
      },
    }
    cb(templates)
  end,
  condition = {
    filetype = { "cpp", "c" },
  },
}
