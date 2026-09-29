local java = require("config.java")
java.attach(0)

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = desc })
end
local function jdtls() return require("jdtls") end

map("n", "<leader>co", function() jdtls().organize_imports() end, "Organize imports")
map("n", "<leader>cv", function() jdtls().extract_variable() end, "Extract variable")
map("x", "<leader>cv", function() jdtls().extract_variable({ visual = true }) end, "Extract variable")
map("n", "<leader>cC", function() jdtls().extract_constant() end, "Extract constant")
map("x", "<leader>cC", function() jdtls().extract_constant({ visual = true }) end, "Extract constant")
map("x", "<leader>cm", function() jdtls().extract_method({ visual = true }) end, "Extract method")
map("n", "<leader>jt", function() java.run("test_file") end, "Run tests in this file")
map("n", "<leader>jT", function() java.run("test_all") end, "Run all tests")
map("n", "<leader>jr", function() java.run("run") end, "Run Spring Boot app")
map("n", "<leader>js", "<cmd>SpringBoot<CR>", "Spring symbols (beans, endpoints…)")
map("n", "<leader>jb", "<cmd>SpringBoot Beans<CR>", "Spring beans")
map("n", "<leader>je", "<cmd>SpringBoot RequestMappings<CR>", "Spring endpoints")
