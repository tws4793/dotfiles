-- Java / Spring Boot / SonarQube plugins. They load only when a Java file needs them;
-- startup logic lives in lua/config/java.lua and ftplugin/java.lua.
return {
  { "mfussenegger/nvim-jdtls", lazy = true },
  { "JavaHello/spring-boot.nvim", lazy = true, config = false }, -- setup() is called on demand
  -- SonarQube for IDE; started on demand by lua/config/sonar.lua
  { url = "https://gitlab.com/schrieveslaach/sonarlint.nvim", name = "sonarlint.nvim", lazy = true, config = false },
}
