-- ~/.config/nvim/init.lua
-- Bootstrapping refatorado com carregamento dinâmico de módulos, logger com namespace e performance

-- Início da medição de performance
local startup_start = vim.loop.hrtime()

-- Variáveis globais
vim.g.python3_host_prog   = "/usr/bin/python3"
vim.g.selected_theme_name = "tokyonight_theme"  -- altere para outro tema em lua/themes/
vim.g.mapleader           = " "
vim.g.maplocalleader      = "\\"
vim.g.editorconfig        = false

-- Função helper para carregar módulos com pcall e notificar falhas
local function try(modname, fallback)
  local ok, mod = pcall(require, modname)
  if not ok then
    vim.notify("[init] Falha ao carregar '" .. modname .. "': " .. tostring(mod), vim.log.levels.ERROR)
    return fallback
  end
  return mod
end

-- Carrega módulo de configuração de debug
local config = try("core.debug.config", {
  silent_mode = false,
  buffer_size = 20,
  flush_interval = 2000,
  performance_log = false,
})

-- Carrega módulos de debug/logger
local debug_mod  = try("core.debug", nil)
local logger_mod = try("core.debug.logger", nil)

-- Determina namespace dinâmico para logger
local log_ns = vim.g.log_namespace or "init"

-- Configura logger padronizado
local logger = logger_mod and logger_mod.get_logger(log_ns) or {
  info = function(_, msg) vim.notify("[init] INFO: " .. msg, vim.log.levels.INFO) end,
  error = function(_, msg) vim.notify("[init] ERRO: " .. msg, vim.log.levels.ERROR) end,
}

-- Wrapper para carregar e logar módulos com profiling opcional
local function load(name)
  local t0 = vim.loop.hrtime()
  local ok = try(name)
  local t1 = vim.loop.hrtime()
  if ok then
    logger.info(log_ns, "Módulo '" .. name .. "' carregado.")
    if config.performance_log and logger_mod and logger_mod.get_buffer then
      local buf = logger_mod.get_buffer()
      buf[#buf + 1] = string.format("[PERF] [%s] load('%s') levou %.2fms\n", log_ns, name, (t1 - t0) / 1e6)
    end
  end
end

-- Carrega configurações core
load("core.options")   -- vim.opt e outras opções básicas
load("core.autocmds")  -- autocommands agrupados

-- Carrega keymaps e utils
load("core.keymaps.init")
require("utils.forensic").enable()

-- Inicializa plugin manager (lazy.nvim)
local lazy = try("plugins.lazy", nil)
if not lazy then return end
logger.info(log_ns, "lazy.nvim inicializado.")

-- Configurações de performance condicional para lazy.nvim
lazy.setup({
  performance = config.performance_log and { rtp = { disabled_plugins = {} } } or nil,
  defaults = { lazy = true },
})

-- Carrega specs de plugins adicionais
load("plugins.which-key")     -- mapeamentos avançados
load("plugins.which-key-lsp") -- integração LSP com which-key

-- Carrega infra do model context protocol
require("infra.mcp").setup()


-- Opcional: carregar automaticamente todos os plugins em lua/plugins
-- for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath('config') .. '/lua/plugins')) do
--   local mod = file:match("(.+)%.lua$")
--   if mod ~= 'lazy' then load('plugins.' .. mod) end
-- end

-- Sinaliza fim do carregamento
if debug_mod then debug_mod.info(log_ns, "Configuração Neovim totalmente carregada.") end
logger.info(log_ns, "Startup completo.")

-- Medição de performance de startup
local startup_end = vim.loop.hrtime()
local elapsed_ms = (startup_end - startup_start) / 1e6
if config.performance_log and logger_mod and logger_mod.get_buffer then
  local buf = logger_mod.get_buffer()
  buf[#buf + 1] = string.format("[PERF] [%s] Startup completed in %.2fms\n", log_ns, elapsed_ms)
end

