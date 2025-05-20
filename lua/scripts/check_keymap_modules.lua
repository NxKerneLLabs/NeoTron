-- scripts/check_keymap_modules.lua
-- Verifica integridade dos módulos de keymaps e detecta conflitos

-- Ícones
local icons_ok, icons = pcall(require, "utils.icons")
if not icons_ok or type(icons.diagnostics) ~= "table" then
  vim.notify("❌ Falha ao carregar utils.icons ou subcampo 'diagnostics'. Usando ícones padrões.", vim.log.levels.WARN)
  icons = {
    success = "✔️",
    error = "❌",
    warn = "⚠️",
    info = "ℹ️",
    debug = "🔍",
  }
else
  icons = {
    success = icons.diagnostics.Ok or "✔️",
    error = icons.diagnostics.Error or "❌",
    warn = icons.diagnostics.Warn or "⚠️",
    info = icons.diagnostics.Info or "ℹ️",
    debug = icons.diagnostics.Debug or "🔍",
  }
end

-- Logger
local logger_ok, core_debug = pcall(require, "core.debug.logger")
local logger = nil
if logger_ok and type(core_debug) == "table" and type(core_debug.get_logger) == "function" then
  logger = core_debug.get_logger("keymaps.modules")
else
  logger = {
    info = function(msg) print(icons.info .. " [keymaps.modules] " .. msg) end,
    warn = function(msg) print(icons.warn .. " [keymaps.modules] " .. msg) end,
    error = function(msg) print(icons.error .. " [keymaps.modules] " .. msg) end,
    debug = function(msg) print(icons.debug .. " [keymaps.modules] " .. msg) end,
    success = function(msg) print(icons.success .. " [keymaps.modules] " .. msg) end,
  }
end

logger.info("Iniciando verificação dos módulos de keymaps...")

-- Tenta carregar a lista de módulos
local ok, modules = pcall(require, "keymaps.modules")
if not ok then
  logger.error("Falha ao carregar keymaps.modules: " .. tostring(modules))
  return
end

local all_ok = true
local keymap_conflicts = {}
local seen_keys = {}

-- Verifica cada módulo
for _, module in ipairs(modules) do
  if type(module) ~= "table" or type(module.path) ~= "string" then
    logger.warn("Entrada inválida na lista de módulos: " .. vim.inspect(module))
    all_ok = false
  else
    local status, result = pcall(require, module.path)
    if status and type(result) == "table" and type(result.get_mappings) == "function" then
      logger.success("OK: " .. module.path)
      -- Verifica conflitos
      local maps = result.get_mappings(icons, logger) or {}
      for _, map in ipairs(maps) do
        local key = map[1]
        if seen_keys[key] then
          table.insert(keymap_conflicts, { key = key, modules = { seen_keys[key], module.path } })
        else
          seen_keys[key] = module.path
        end
      end
    elseif status then
      logger.warn("Módulo " .. module.path .. " carregou mas não tem função `get_mappings`")
      all_ok = false
    else
      logger.error("Erro ao carregar: " .. module.path .. " - " .. tostring(result))
      all_ok = false
    end
  end
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
  logger.success("Todos os módulos carregados com sucesso! 🎉")
else
  logger.warn("Alguns módulos falharam ou há conflitos. Verifique os logs acima. 🚧")
end

