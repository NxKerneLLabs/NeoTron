-- ~/.config/nvim/init.lua
vim.g.python3_host_prog = "/usr/bin/python3"
-- Defina o nome do arquivo do tema que você quer usar (da pasta lua/themes/)
vim.g.selected_theme_name = "tokyonight_theme" -- Mude para "catppuccin_theme", "nord_theme", "tokyonight_theme" etc.

-- 1. Carregue configurações 'core' super essenciais primeiro
-- Configurações básicas de opções do Neovim
local options_ok, _ = pcall(require, "core.options")
if not options_ok then
  vim.notify("Erro ao carregar 'core.options'. Verifique o arquivo.", vim.log.levels.ERROR)
end

-- Carregamento do módulo de debug com proteção contra falhas
local logger
local debug_ok, debug = pcall(require, "core.debug")
if not debug_ok then
  vim.notify("Erro ao carregar 'core.debug'. Usando fallback básico para logging.", vim.log.levels.ERROR)
  -- Fallback básico para logging caso core.debug falhe
  debug = {
    info = function(ns, msg) vim.notify("[INFO][" .. ns .. "] " .. msg, vim.log.levels.INFO) end,
    error = function(ns, msg) vim.notify("[ERROR][" .. ns .. "] " .. msg, vim.log.levels.ERROR) end,
    warn = function(ns, msg) vim.notify("[WARN][" .. ns .. "] " .. msg, vim.log.levels.WARN) end,
    debug = function(ns, msg) vim.notify("[DEBUG][" .. ns .. "] " .. msg, vim.log.levels.DEBUG) end,
    wrap_register = function(original, ns, name)
      return function(mappings, opts)
        vim.notify("[DEBUG][" .. ns .. "] Usando fallback para " .. name, vim.log.levels.DEBUG)
        return original(mappings, opts)
      end
    end
  }
else
  vim.notify("Módulo 'core.debug' carregado com sucesso.", vim.log.levels.INFO)
end

-- Notificação inicial usando o debug ou fallback
debug.info("init", "Neovim core carregando. Inicializando plugins...")

-- 2. Chame o seu configurador do lazy.nvim
local status_ok_lazy, _ = pcall(require, "plugins.lazy")
if not status_ok_lazy then
  debug.error("init", "Erro crítico ao carregar o gestor de plugins (plugins.lazy). Verifique os logs.")
  return
end
debug.info("init", "Gestor de plugins (lazy.nvim) carregado com sucesso.")

-- 3. Carregue autocmds e seu carregador central de keymaps
local autocmds_ok, _ = pcall(require, "core.autocmds")
if not autocmds_ok then
  debug.error("init", "Erro ao carregar 'core.autocmds'. Verifique o arquivo.")
else
  debug.info("init", "Autocommands carregados com sucesso.")
end

local keymaps_ok, _ = pcall(require, "keymaps.init")
if not keymaps_ok then
  debug.error("init", "Erro ao carregar 'core.keymaps'. Verifique o arquivo.")
else
  debug.info("init", "Keymaps carregados com sucesso.")
end

require("utils.forensic")  -- registra os comandos
-- opcionalmente já habilita:
-- require("utils.forensic").enable()


-- O colorscheme será aplicado pelo arquivo de tema específico.
-- Não é mais necessário definir vim.cmd.colorscheme aqui, a menos que seja um fallback.
debug.info("init", "Configuração do Neovim carregada com sucesso!")

