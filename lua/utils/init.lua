-- nvim/lua/utils/init.lua
-- Este arquivo serve como o ponto de entrada para o pacote 'utils'.
-- Ele pode carregar e expor outros módulos dentro do diretório 'utils'.
local logger
local debug_ok, debug = pcall(require, "core.debug.logger")
if not debug_ok then
  debug = {
    info = function(msg) vim.notify("UTILS INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("UTILS ERROR: " .. msg, vim.log.levels.ERROR) end,
  }
  debug.error("core.debug module not found for utils/init.lua.")
end

debug.info("Loading 'utils' package (lua/utils/init.lua)...")

local utils_namespace = {}

-- Carregar e expor o módulo de ícones
local icons_module_ok, icons_content = pcall(require, "utils.icons")
if icons_module_ok then
  utils_namespace.icons = icons_content
  debug.info("'utils.icons' loaded and exposed as 'utils.icons'.")
else
  debug.error("Failed to load 'utils.icons' module: " .. tostring(icons_content))
  utils_namespace.icons = {} -- Fornecer uma tabela vazia como fallback
end

-- Se você tiver outros módulos utilitários no futuro, pode carregá-los aqui também:
-- Exemplo:
-- local other_util_ok, other_util_content = pcall(require, "utils.outromodulo")
-- if other_util_ok then
--   utils_namespace.outro = other_util_content
--   debug.info("'utils.outromodulo' loaded and exposed as 'utils.outro'.")
-- else
--   debug.error("Failed to load 'utils.outromodulo': " .. tostring(other_util_content))
-- end

debug.info("'utils' package initialized.")
return utils_namespace

