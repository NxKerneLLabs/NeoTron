-- lua/core/appearance.lua
-- Configurações de aparência e interface do Neovim

local debug = require("core.debug.logger")
local logger = debug
local opt = vim.opt
local g = vim.g

logger.info("Carregando configurações de aparência (lua/core/appearance.lua)...")

-- Numeração
opt.number = true          -- Mostra números de linha
opt.relativenumber = true  -- Números relativos para navegação

-- Destaques
opt.cursorline = true      -- Destaca a linha atual do cursor

-- Cores
opt.termguicolors = true   -- Cores 24-bit

-- Sinalização
opt.signcolumn = "yes"    -- Coluna de sinais sempre visível

-- Colunas de limite
opt.colorcolumn = "80,120" -- Linhas verticais nas colunas 80 e 120

-- Modo e linha de comando
opt.showmode = false       -- Plugins cuidam de mostrar modo
opt.cmdheight = 1          -- Altura da linha de comando

-- Contexto de rolagem
opt.scrolloff = 10         -- Linhas acima/abaixo ao rolar
opt.sidescrolloff = 8      -- Colunas à esquerda/direita ao rolar

-- Statusline global
opt.laststatus = 3         -- Usado por plugins como lualine

-- Caracteres invisíveis
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "➩",
  precedes = "➨",
}

-- Mouse e clipboard
opt.mouse = "a"           -- Suporte ao mouse em todos modos
opt.clipboard = "unnamedplus" -- Usa clipboard do sistema

-- Menu de autocompletar
opt.pumheight = 10         -- Altura do popup

logger.info("Configurações de aparência carregadas e aplicadas.")

