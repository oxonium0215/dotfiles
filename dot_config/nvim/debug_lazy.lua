local langs = require("plugins.configs.lsp.langs")
local lazy_install = require("core.lazy_install")

print("--- Debugging Lazy Install ---")

-- Check langs.all()
local all = langs.all()
print("Available languages in langs.all():")
for k, _ in pairs(all) do
  print(" - " .. k)
end

if all["c"] then
  print("Found 'c' config:")
  print(vim.inspect(all["c"]))
else
  print("ERROR: 'c' config NOT found!")
end

-- Check get_tools("c")
print("\nChecking tools for filetype 'c':")
local tools = lazy_install.get_tools("c")
print("Tools found: " .. vim.inspect(tools))

-- Check Mason registry for clangd
local registry = require("mason-registry")
local ok, pkg = pcall(registry.get_package, "clangd")
if ok then
  print("Mason package 'clangd' exists.")
  print("Is installed: " .. tostring(pkg:is_installed()))
else
  print("Mason package 'clangd' NOT found.")
end
