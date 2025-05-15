-- scripts/check_keymap_modules.lua

local icons_ok, icons = pcall(require, "utils.icons")
if not icons_ok then
  vim.notify("❌ Falha ao carregar utils.icons. Caindo para ícones padrões.", vim.log.levels.WARN)
  icons = {
    success = "✔️",
    error = "❌",
    warn = "⚠️",
    info = "ℹ️",
    debug = "🔍",
  }
elseif type(icons.diagnostics) == "table" then
  icons = {
    success = icons.diagnostics.Ok or "✔️",
    error = icons.diagnostics.Error or "❌",
    warn = icons.diagnostics.Warn or "⚠️",
    info = icons.diagnostics.Info or "ℹ️",
    debug = icons.diagnostics.Debug or "🔍",
  }
else
  vim.notify("❌ utils.icons carregado mas sem subcampo 'diagnostics'. Usando ícones padrões.", vim.log.levels.WARN)
  icons = {
    success = "✔️",
    error = "❌",
    warn = "⚠️",
    info = "ℹ️",
    debug = "🔍",
  }
end

-- Logger
local logger = nil
local logger_ok, core_debug = pcall(require, "core.debug.logger")
if logger_ok and type(core_debug) == "table" then
  logger = type(core_debug.get_logger) == "function"
    and core_debug.get_logger("check_keymap_modules")
    or core_debug
end

local function create_fallback_logger(prefix)
  return {
    info = function(msg) print(icons.info .. " [" .. prefix .. "] " .. msg) end,
    warn = function(msg) print(icons.warn .. " [" .. prefix .. "] " .. msg) end,
    error = function(msg) print(icons.error .. " [" .. prefix .. "] " .. msg) end,
    debug = function(msg) print(icons.debug .. " [" .. prefix .. "] " .. msg) end,
    success = function(msg) print(icons.success .. " [" .. prefix .. "] " .. msg) end,
  }
end

logger = logger or create_fallback_logger("check_keymap_modules")

-- Tenta carregar a lista de módulos
local ok, modules = pcall(require, "keymaps.module_list")
if not ok then
  logger.error("Falha ao carregar keymaps.module_list: " .. tostring(modules))
  return
end

logger.info("Iniciando verificação dos módulos de keymaps...")

local all_ok = true

for _, module in ipairs(modules) do
  if type(module) == "table" and type(module.path) == "string" then
    local status, result = pcall(require, module.path)
    if status and type(result) == "table" and type(result.get_mappings) == "function" then
      logger.success("OK: " .. module.path)
    elseif status then
      logger.warn("Módulo " .. module.path .. " carregou mas não tem função `get_mappings`")
      all_ok = false
    else
      logger.error("Erro ao carregar: " .. module.path .. " - " .. tostring(result))
      all_ok = false
    end
  else
    logger.warn("Entrada inválida na lista de módulos: " .. vim.inspect(module))
    all_ok = false
  end
end

if all_ok then
  logger.success("Todos os módulos carregados com sucesso! 🎉")
else
  logger.warn("Alguns módulos falharam. Verifique os logs acima. 🚧")
end




