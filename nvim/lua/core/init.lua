-- ~/.config/nvim/lua/core/init.lua
local M = {}

-- Tempo de início para métricas
M.start_time = vim.loop.hrtime()

-- Log de emergência (consistente com o init.lua principal)
local function emergency_log(msg)
  vim.schedule(function()
    vim.api.nvim_echo({{"[CORE] " .. msg, "WarningMsg"}}, true, {})
    io.write("[NVIM_CORE] " .. os.date("%H:%M:%S") .. " " .. msg .. "\n")
  end)
end

-- Carregamento seguro de módulos
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    emergency_log("Falha ao carregar " .. module .. ": " .. result)
    return nil
  end
  return result
end

-- Módulos core na ordem de dependência
local core_modules = {
  "core.options",        -- Configurações básicas primeiro
  "core.keymaps",        -- Keymaps por último
}

-- Função principal de setup
function M.setup()
  local failed_modules = {}
  
  -- Carrega cada módulo com tratamento de erro
  for _, module in ipairs(core_modules) do
    local loaded = safe_require(module)
    if not loaded then
      table.insert(failed_modules, module)
      emergency_log("ERRO: Módulo crítico falhou: " .. module)
    end
  end
  
  -- Reporta estatísticas de carregamento
  local loaded_count = #core_modules - #failed_modules
  local startup_time = (vim.loop.hrtime() - M.start_time) / 1e6
  
  if #failed_modules == 0 then
    -- Usa o logger se disponível, senão usa emergency_log
    if package.loaded["core.debug.logger"] then
      require("core.debug.logger").info(
        string.format("Core carregado com sucesso (%d/%d módulos, %.2fms)", 
                      loaded_count, #core_modules, startup_time)
      )
    else
      emergency_log(string.format("Core carregado (%d/%d módulos, %.2fms)", 
                                  loaded_count, #core_modules, startup_time))
    end
  else
    emergency_log(string.format("Core carregado com erros (%d/%d módulos, %.2fms)",
                                loaded_count, #core_modules, startup_time))
  end
  
  return #failed_modules == 0
end

-- Função de diagnóstico/saúde do sistema
function M.health_check()
  local issues = {}
  
  -- Verifica se os módulos core estão carregados
  for _, module in ipairs(core_modules) do
    if not package.loaded[module] then
      table.insert(issues, "Módulo não carregado: " .. module)
    end
  end
  
  -- Verifica leader keys
  if not vim.g.mapleader then
    table.insert(issues, "mapleader não definido")
  end
  
  if not vim.g.maplocalleader then
    table.insert(issues, "maplocalleader não definido")
  end
  
  return #issues == 0, issues
end

-- Função para recarregar o core (útil para desenvolvimento)
function M.reload()
  -- Limpa o cache dos módulos core
  for _, module in ipairs(core_modules) do
    package.loaded[module] = nil
  end
  
  -- Limpa este módulo também
  package.loaded["core"] = nil
  
  -- Recarrega
  return require("core").setup()
end

-- Função init para compatibilidade com seu código atual
function M.init()
  return M.setup()
end

return M

