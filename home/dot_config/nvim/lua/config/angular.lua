-- Angular: template-aware language server (bindings, control flow, component
-- inputs/outputs), on top of vtsls/html/cssls from lsp.lua.
-- angular-language-server is installed the first time you open a file inside
-- an Angular project, so machines without Angular work never download it.

vim.filetype.add({
  pattern = { [".*%.component%.html"] = "htmlangular" },
})

vim.lsp.config("angularls", {
  workspace_required = true, -- only inside Angular workspaces, never in plain TS/React
})

local function is_angular_project(root)
  if vim.uv.fs_stat(vim.fs.joinpath(root, "angular.json")) then return true end
  local ok, pkg = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(vim.fs.joinpath(root, "package.json")), "\n"))
  end)
  if not ok or type(pkg) ~= "table" then return false end
  return (pkg.dependencies or {})["@angular/core"] ~= nil or (pkg.devDependencies or {})["@angular/core"] ~= nil
end

local checked = {}
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_angular", { clear = true }),
  pattern = { "typescript", "html", "htmlangular" },
  callback = function(args)
    local root = vim.fs.root(args.buf, { "angular.json", "package.json" })
    if not root or checked[root] then return end
    checked[root] = true
    if is_angular_project(root) then
      -- Once installed, mason-lspconfig enables angularls and it attaches to open buffers.
      require("config.tools").ensure({ "angular-language-server" }, function() end)
    end
  end,
})
