-- ~/.config/nvim/init.lua
vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.selected_theme_name = "tokyonight"
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.editorconfig = false

-- 1. Core debug
local debug_ok, debug_err = pcall(require, "core.debug")
if not debug_ok then
  vim.notify("Erro ao carregar 'core.debug': " .. tostring(debug_err), vim.log.levels.ERROR)
end

-- 2. Opções básicas
local ok, err = pcall(require, "core.options")
if not ok then
  vim.notify("Erro ao carregar 'core.options': " .. tostring(err), vim.log.levels.ERROR)
end

-- 3. Logger
local logger
local logger_ok, logger_mod = pcall(require, "core.debug.logger")
if logger_ok and type(logger_mod.get_logger) == "function" then
  logger = logger_mod.get_logger("init")
else
  logger = {
    info = function(_, msg) vim.notify("[init] INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(_, msg) vim.notify("[init] ERROR: " .. msg, vim.log.levels.ERROR) end,
  }
end

-- 4. Lazy.nvim
local plugins_ok, err_plugins = pcall(require, "plugins.lazy")
if not plugins_ok then
  logger.error("init", "Erro ao carregar plugins.lazy: " .. tostring(err_plugins))
  return
end
logger.info("init", "lazy.nvim carregado.")

-- 5. Autocmds e keymaps
local autocmds_ok, err_autocmds = pcall(require, "core.autocmds")
if not autocmds_ok then
  logger.error("init", "Erro ao carregar core.autocmds: " .. tostring(err_autocmds))
else
  logger.info("init", "Autocmds carregados.")
end

local keymaps_ok, err_keymaps = pcall(require, "core.keymaps.init")
if not keymaps_ok then
  logger.error("init", "Erro ao carregar core.keymaps: " .. tostring(err_keymaps))
else
  logger.info("init", "Keymaps carregados.")
end

-- 6. Which-key
local wk_ok, err_wk = pcall(require, "plugins.which-key")
if not wk_ok then
  logger.error("init", "Erro ao carregar plugins.which-key: " .. tostring(err_wk))
else
  logger.info("init", "Which-key carregado.")
end

logger.info("init", "Configuração do Neovim concluída com sucesso!")
