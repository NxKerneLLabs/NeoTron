-- lua/core/options.lua
-- Configurações globais do Neovim

local debug = require("core.debug") -- Declarar dependências usadas no módulo
local opt = vim.opt
local g = vim.g
local fn = vim.fn

debug.info("Carregando opções globais do Neovim (lua/core/options.lua)...")

-- Interface e aparência
opt.number = true          -- Mostra números de linha
opt.relativenumber = true  -- Números relativos para navegação (controlado também por autocmds)
opt.cursorline = true      -- Destaca a linha atual do cursor
opt.termguicolors = true   -- Habilita cores verdadeiras de 24-bit no terminal
opt.signcolumn = "yes"     -- Sempre mostra a coluna de sinais (para git, lsp, etc.)
opt.colorcolumn = "80,120" -- Linhas verticais nos limites de 80 e 120 colunas
opt.showmode = false       -- Não mostra o modo atual (plugins como lualine cuidam disso)
opt.cmdheight = 1          -- Altura da linha de comando (0 pode ser usado com plugins específicos)
opt.scrolloff = 10         -- Mantém 10 linhas de contexto ao rolar verticalmente
opt.sidescrolloff = 8      -- Mantém 8 colunas de contexto ao rolar horizontalmente
opt.laststatus = 3         -- Sempre mostra a statusline global (para lualine)

-- Comportamento de edição
opt.tabstop = 2        -- Número de espaços que um <Tab> no arquivo conta como
opt.softtabstop = 2    -- Número de espaços que um <Tab> insere/remove em modo de edição
opt.shiftwidth = 2     -- Número de espaços para indentação automática
opt.expandtab = true   -- Converte <Tab> em espaços
opt.smartindent = true -- Indentação inteligente para novas linhas
opt.autoindent = true  -- Copia a indentação da linha atual para a nova linha
opt.wrap = false       -- Não quebra linhas longas automaticamente
opt.linebreak = true   -- Quebra linhas em palavras (se 'wrap' estivesse ativo ou para formatação)
opt.list = true        -- Mostra caracteres invisíveis (configurados em listchars)
opt.listchars = {      -- Configuração dos caracteres invisíveis
  tab = "» ",          -- Caractere para tabulação
  trail = "·",         -- Caractere para espaços no final da linha
  nbsp = "␣",          -- Caractere para non-breaking space
  extends = "⟩",       -- Caractere para linhas que continuam além da tela (com wrap desativado)
  precedes = "⟨",      -- Caractere para linhas que começam antes da tela
}
opt.formatoptions:remove({ "c", "r", "o" }) -- Evita comentários automáticos em novas linhas

-- Busca e substituição
opt.hlsearch = true    -- Destaca todos os resultados da busca
opt.incsearch = true   -- Mostra resultados da busca incrementalmente enquanto digita
opt.ignorecase = true  -- Ignora maiúsculas/minúsculas na busca
opt.smartcase = true   -- Torna a busca sensível a maiúsculas/minúsculas se houver letras maiúsculas no padrão

-- Sistema e performance
opt.hidden = true         -- Permite esconder buffers modificados sem salvar
opt.errorbells = false    -- Desativa sinos de erro sonoros ou visuais
opt.swapfile = false      -- Desativa a criação de arquivos de swap (.swp)
opt.backup = false        -- Desativa a criação de arquivos de backup (~)
local undodir_path = fn.stdpath("data") .. "/undo"
opt.undodir = undodir_path -- Diretório para arquivos de undo persistente
opt.undofile = true       -- Habilita undo persistente entre sessões

-- Cria o diretório de undo se não existir
if not (fn.isdirectory(undodir_path) == 1) then
  pcall(fn.mkdir, undodir_path, "p", 0700)
  debug.info("Diretório de undo criado em: " .. undodir_path)
end

opt.updatetime = 300   -- Tempo em milissegundos para o evento CursorHold (usado por LSPs, etc.)
opt.timeoutlen = 500   -- Tempo em milissegundos para esperar por sequências de mapeamento de teclas
opt.ttimeoutlen = 10   -- Tempo em milissegundos para esperar por códigos de escape de teclas (para <Esc> mais rápido)

-- Janelas e splits
opt.splitbelow = true  -- Novos splits horizontais abrem abaixo do atual
opt.splitright = true  -- Novos splits verticais abrem à direita do atual

-- Configurações adicionais para plugins e comportamento
opt.completeopt = "menu,menuone,noselect" -- Opções de autocompletar (bom para nvim-cmp)
opt.mouse = "a"        -- Habilita o uso do mouse em todos os modos (normal, visual, insert, command)
opt.clipboard = "unnamedplus" -- Usa o clipboard do sistema para yank/paste (requer xclip/wl-copy/etc.)
opt.pumheight = 10     -- Altura máxima do menu pop-up de autocompletar

-- Líder global (mapleader) e local (maplocalleader)
-- Definido aqui para garantir que esteja disponível quando os keymaps forem carregados.
g.mapleader = " "      -- Define <leader> como a tecla Espaço
g.maplocalleader = "\\" -- Define <localleader> como a tecla Barra Invertida (exemplo)

debug.info("Opções globais do Neovim (lua/core/options.lua) carregadas e configuradas!")

