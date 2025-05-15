-- lua/core/options.lua
-- Configurações globais do Neovim
local logger = require("core.debug.logger")
local opt = vim.opt
local g = vim.g
local fn = vim.fn

logger.info("Carregando opções globais do Neovim (lua/core/options.lua)...")

-- Interface e aparência gerenciadas em core/appearance.lua
require("core.appearance")

-- Comportamento de edição
opt.tabstop = 2            -- Número de espaços que um <Tab> no arquivo conta como
opt.softtabstop = 2        -- Número de espaços que um <Tab> insere/remove em modo de edição
opt.shiftwidth = 2         -- Número de espaços para indentação automática
opt.expandtab = true       -- Converte <Tab> em espaços
opt.smartindent = true     -- Indentação inteligente para novas linhas
opt.autoindent = true      -- Copia a indentação da linha atual para a nova linha
opt.wrap = false           -- Não quebra linhas longas automaticamente
opt.linebreak = true       -- Quebra linhas em palavras

-- Busca e substituição
opt.hlsearch = true        -- Destaca todos os resultados da busca
opt.incsearch = true       -- Busca incremental
opt.ignorecase = true      -- Ignora maiúsculas/minúsculas na busca
opt.smartcase = true       -- Sensível a maiúsculas se houver uppercase no padrão

-- Sistema e performance
opt.hidden = true          -- Esconde buffers modificados sem salvar
opt.errorbells = false     -- Desativa sinos de erro
opt.swapfile = false       -- Desativa arquivos de swap (.swp)
opt.backup = false         -- Desativa arquivos de backup (~)

local undodir = fn.stdpath("data") .. "/undo"
opt.undodir = undodir     -- Diretório para undo persistente
opt.undofile = true       -- Ativa undo persistente

-- Cria diretório de undo
if fn.isdirectory(undodir) ~= 1 then
  pcall(fn.mkdir, undodir, "p", "0700")
  logger.info("Diretório de undo criado em: " .. undodir)
end

opt.updatetime = 300       -- Atualiza CursorHold a cada 300ms
opt.timeoutlen = 500       -- Espera de mapeamentos
opt.ttimeoutlen = 10       -- Espera por escape sequence curto

-- Splits
opt.splitbelow = true      -- Splits horizontais abrem abaixo
opt.splitright = true      -- Splits verticais abrem à direita

-- Configurações adicionais
opt.completeopt = "menu,menuone,noselect" -- Autocompletar ideal para nvim-cmp
opt.mouse = "a"           -- Mouse em todos modos
opt.clipboard = "unnamedplus" -- Usa clipboard do sistema
opt.pumheight = 10         -- Altura do popup de completions

logger.info("Opções globais carregadas e configuradas com sucesso.")

