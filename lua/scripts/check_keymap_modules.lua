-- scripts/check_keymap_modules.lua
-- Verifica integridade dos módulos de keymaps e detecta conflitos

local function safe_require(mod, logger)
  local ok, res = pcall(require, mod)
  if not ok then logger.error("Failed to load " .. mod .. ": " .. res) end
  return ok and res
end

-- Logger
local logger_mod = safe_require("core.debug.logger", { error = print })
local logger = logger_mod and logger_mod.get_logger and logger_mod.get_logger("check_keymap_modules") or {
  debug = function(m) print("[check_keymap_modules] DEBUG: " .. m) end,
  info = print, warn = print, error = print, success = print
}

-- Ícones
local icons = safe_require("utils.icons", logger) or {}
local icon_map = {
  success = icons.diagnostics and icons.diagnostics.Ok or "✔️",
  error = icons.diagnostics and icons.diagnostics.Error or "❌",
  warn = icons.diagnostics and icons.diagnostics.Warn or "⚠️",
  info = icons.diagnostics and icons.diagnostics.Info or "ℹ️",
  debug = icons.diagnostics and icons.diagnostics.Debug or "🔍",
}

logger.info("Verificando módulos de keymaps...")

-- Carrega módulos
local modules = safe_require("keymaps.module_list", logger) or {}
if not modules then return end

local all_ok = true
local keymap_conflicts = {}
local seen_keys = {}

-- Verifica cada módulo
for _, module in ipairs(modules) do
  if type(module) ~= "table" or type(module.path) ~= "string" then
    logger.warn("Entrada inválida: " .. vim.inspect(module))
    all_ok = false
    goto continue
  end

  local mod = safe_require(module.path, logger)
  if not mod then
    all_ok = false
    goto continue
  end

  if type(mod.get_mappings) ~= "function" then
    logger.warn("Módulo " .. module.path .. " sem função `get_mappings`")
    all_ok = false
    goto continue
  end

  -- Verifica conflitos
  local maps = mod.get_mappings(icons, logger) or {}
  for _, map in ipairs(maps) do
    local key = map[1]
    if seen_keys[key] then
      table.insert(keymap_conflicts, { key = key, modules = { seen_keys[key], module.path } })
    else
      seen_keys[key] = module.path
    end
  end

  logger.success("OK: " .. module.path)

  ::continue::
end

-- Relatório de conflitos
if #keymap_conflicts > 0 then
  logger.warn("Conflitos de keymaps detectados:")
  for _, conflict in ipairs(keymap_conflicts) do
    logger.warn("  Chave '" .. conflict.key .. "' usada em: " .. table.concat(conflict.modules, ", "))
  end
  all_ok = false
end

-- Resumo
if all_ok then
  logger.success("Todos os módulos OK! 🎉")
else
  logger.warn("Problemas encontrados. Verifique os logs. 🚧")
end
