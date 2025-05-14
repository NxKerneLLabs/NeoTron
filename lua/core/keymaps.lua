-- lua/core/keymaps.lua
-- Define keymaps centrais do Neovim e carrega módulos de keymaps GERAIS
-- que NÃO são para os menus do which-key.nvim.

local debug_ok, debug = pcall(require, "core.debug")
if not debug_ok then
  debug = { info = function(msg) vim.notify("CORE_KEYMAPS INFO: " .. msg, vim.log.levels.INFO) end,
            error = function(msg) vim.notify("CORE_KEYMAPS ERROR: " .. msg, vim.log.levels.ERROR) end,
            warn = function(msg) vim.notify("CORE_KEYMAPS WARN: " .. msg, vim.log.levels.WARN) end }
  debug.error("core.debug module not found for core/keymaps.lua.")
end

local map = vim.keymap.set
local g = vim.g

debug.info("Carregando keymaps centrais e gerais (lua/core/keymaps.lua)...")

-- -----------------------------------------------------------------------------
-- Keymaps Essenciais do Neovim (Definidos diretamente aqui)
-- -----------------------------------------------------------------------------
local leader = g.mapleader or " "

map("n", leader .. "w", "<cmd>write<cr>", { desc = "Salvar arquivo [W]rite" })
map("n", leader .. "W", "<cmd>wall<cr>", { desc = "Salvar todos os arquivos [W]rite [A]ll" })
map("n", leader .. "q", "<cmd>quit<cr>", { desc = "Sair do buffer atual [Q]uit" })
map("n", leader .. "Q", "<cmd>qa!<cr>", { desc = "Sair de tudo (forçado) [Q]uit [A]ll" })
map("n", "<Esc>", "<cmd>noh<cr><Esc>", { desc = "Limpar highlight da busca e ESC", silent = true })
map("n", leader .. "<Esc>", "<cmd>noh<cr>", { desc = "Limpar highlight da busca [No H]ighlight" })
map("n", "<C-h>", "<C-w>h", { desc = "Mover para janela à Esquerda", silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Mover para janela Abaixo", silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Mover para janela Acima", silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Mover para janela à Direita", silent = true })

debug.debug("Keymaps essenciais do Neovim definidos em core/keymaps.lua.")

-- -----------------------------------------------------------------------------
-- Carregador Dinâmico para Módulos de Keymaps GERAIS (NÃO which-key)
-- -----------------------------------------------------------------------------
debug.info("Carregando módulos de keymaps GERAIS (não-which-key)...")


local general_keymap_modules_to_load = {
  "keymaps.general",
  "keymaps.dap", 
  "keymaps.git", 
}

if #general_keymap_modules_to_load == 0 then
  debug.info("Nenhum módulo de keymap GERAL listado para carregar em core/keymaps.lua.")
else
  local all_general_modules_loaded_successfully = true
  for _, module_name in ipairs(general_keymap_modules_to_load) do
    local keymap_module = nil
    local load_ok, err_msg_load = pcall(function() keymap_module = require(module_name) end)

    if load_ok and keymap_module then
      if type(keymap_module.register) == "function" then
        local register_ok, err_msg_register = pcall(keymap_module.register) -- Não passa 'wk' aqui
        if register_ok then
          debug.debug("Keymaps GERAIS do módulo '" .. module_name .. "' registrados.")
        else
          debug.error("Erro no .register() GERAL de '" .. module_name .. "': " .. tostring(err_msg_register))
          all_general_modules_loaded_successfully = false
        end
      else
        debug.warn("Módulo GERAL '" .. module_name .. "' carregado, mas sem função 'register'.")
      end
    else
      debug.error("Falha crítica ao carregar módulo GERAL: " .. module_name .. ". Erro: " .. tostring(err_msg_load))
      all_general_modules_loaded_successfully = false
    end
  end
  if not all_general_modules_loaded_successfully then
    debug.warn("Alguns módulos de keymaps GERAIS tiveram problemas.")
  end
end

debug.info("Carregamento de keymaps (lua/core/keymaps.lua) concluído.")

