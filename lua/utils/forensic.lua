-- lua/utils/forensic.lua
-- Módulo de diagnóstico forense para Neovim/Lua
-- Insira este arquivo em 'lua/utils/forensic.lua' e habilite em seu init.

local M = {}
M.enabled = false

-- Guarda o require original
local original_require = require

-- Função para exibir notificações rápidas
local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO)
  end)
end

-- Wrapper de require para logar chamadas
local function wrapped_require(name)
  notify(string.format("📦 [Forensic] require: %s", name), vim.log.levels.DEBUG)
  local result = original_require(name)
  if result == nil then
    notify(string.format("❗ [Forensic] require(%s) retornou nil", name), vim.log.levels.WARN)
  end
  return result
end

-- Intercepta require globalmente
function M.enable()
  if M.enabled then
    notify("[Forensic] Já ativado.")
    return
  end
  M.enabled = true
  package._orig_searchers = package.searchers or package.loaders
  -- Log de package.path e cpath
  notify("[Forensic] PATH: " .. package.path)
  notify("[Forensic] CPATH: " .. package.cpath)

  -- Log de cada searcher
  local wrapped_searchers = {}
  for i, searcher in ipairs(package._orig_searchers) do
    wrapped_searchers[i] = function(module_name)
      notify(string.format("🔍 [Forensic] searcher #%d for %s", i, module_name), vim.log.levels.DEBUG)
      return searcher(module_name)
    end
  end
  package.searchers = wrapped_searchers

  -- Sobrescreve require
  _G.require = wrapped_require
  notify("[Forensic] Diagnóstico ativado.", vim.log.levels.WARN)
end

function M.disable()
  if not M.enabled then
    notify("[Forensic] Não está ativado.")
    return
  end
  M.enabled = false
  -- Restaura require
  _G.require = original_require
  package.searchers = package._orig_searchers
  notify("[Forensic] Diagnóstico desativado.", vim.log.levels.WARN)
end

-- Exibe stacktrace de um erro
function M.trace(err)
  local tb = debug.traceback(err, 2)
  notify("🔗 [Forensic] Traceback:\n" .. tb, vim.log.levels.ERROR)
end

-- Comandos de usuário
vim.api.nvim_create_user_command('ForensicEnable', function() M.enable() end, {})
vim.api.nvim_create_user_command('ForensicDisable', function() M.disable() end, {})
vim.api.nvim_create_user_command('ForensicTrace', function(opts)
  M.trace(opts.args)
end, { nargs = '*' })

return M

