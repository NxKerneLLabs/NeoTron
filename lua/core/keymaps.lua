--- lua/core/keymaps.lua
local debug_ok, debug = pcall(require, "core.debug.logger")
local logger = debug_ok and debug.get_logger("core.keymaps") or {
  info = function(msg) vim.notify("[core.keymaps INFO] "..msg, vim.log.levels.INFO) end,
  warn = function(msg) vim.notify("[core.keymaps WARN] "..msg, vim.log.levels.WARN) end,
  error = function(msg) vim.notify("[core.keymaps ERROR] "..msg, vim.log.levels.ERROR) end,
  debug = function(msg) vim.notify("[core.keymaps DEBUG] "..msg, vim.log.levels.DEBUG) end,
}
if not debug_ok then
  logger.warn("core.debug.logger não encontrado: usando fallback.")
end

logger.info("Carregando keymaps centrais básicos...")

local opts = { noremap = true, silent = true }
-- agrupando keymaps em tabela para fácil manutenção
local keymap_defs = {
  -- navegação entre splits
  {mode = "n", lhs = "<C-h>", rhs = "<C-w>h"},
  {mode = "n", lhs = "<C-j>", rhs = "<C-w>j"},
  {mode = "n", lhs = "<C-k>", rhs = "<C-w>k"},
  {mode = "n", lhs = "<C-l>", rhs = "<C-w>l"},
  -- limpar search highlight
  {mode = "n", lhs = "<Esc>", rhs = "<cmd>noh<CR>"},
  -- redimensionar splits
  {mode = "n", lhs = "<A-Left>",  rhs = ":vertical resize -2<CR>"},
  {mode = "n", lhs = "<A-Right>", rhs = ":vertical resize +2<CR>"},
  {mode = "n", lhs = "<A-Up>",    rhs = ":resize +2<CR>"},
  {mode = "n", lhs = "<A-Down>",  rhs = ":resize -2<CR>"},
}
for _, map in ipairs(keymap_defs) do
  vim.keymap.set(map.mode, map.lhs, map.rhs, opts)
end

logger.debug("Keymaps essenciais definidos.")
logger.info("Keymaps centrais básicos concluídos.")


--- lua/core/options.lua
local debug_ok, debug = pcall(require, "core.debug.logger")
local logger = debug_ok and debug.get_logger("core.options") or {
  info = function(msg) vim.notify("[core.options INFO] "..msg, vim.log.levels.INFO) end,
  warn = function(msg) vim.notify("[core.options WARN] "..msg, vim.log.levels.WARN) end,
  error = function(msg) vim.notify("[core.options ERROR] "..msg, vim.log.levels.ERROR) end,
  debug = function(msg) vim.notify("[core.options DEBUG] "..msg, vim.log.levels.DEBUG) end,
}
if not debug_ok then
  logger.warn("core.debug.logger não encontrado: usando fallback.")
end

logger.info("Carregando opções globais...")

local opt = vim.opt
local g = vim.g
local fn = vim.fn

-- interface e aparência
require("core.appearance")

-- edição
opt.tabstop      = 2
opt.softtabstop  = 2
opt.shiftwidth   = 2
opt.expandtab    = true
opt.smartindent  = true
opt.autoindent   = true
opt.wrap         = false
opt.linebreak    = true

-- busca
opt.hlsearch     = true
opt.incsearch    = true
opt.ignorecase   = true
opt.smartcase    = true

-- sistema e performance
opt.errorbells   = false
opt.swapfile     = false
opt.backup       = false

-- undo persistente
txt = fn.stdpath("data").."/undo"
opt.undodir      = txt
opt.undofile     = true
if fn.isdirectory(txt) ~= 1 then
  pcall(fn.mkdir, txt, "p", "0700")
  logger.info("Diretório de undo criado em: "..txt)
end

-- autocmds em augroup para formatoptions
local group = vim.api.nvim_create_augroup("CoreOptions", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "*",
  desc    = "Remove auto-comment formatoptions c,r,o",
  callback = function()
    vim.opt.formatoptions:remove({"c","r","o"})
  end,
})

opt.updatetime   = 300
opt.timeoutlen   = 500
opt.ttimeoutlen  = 10

opt.splitbelow   = true
opt.splitright   = true
opt.completeopt  = "menu,menuone,noselect"
opt.mouse        = "a"
opt.clipboard    = "unnamedplus"
opt.pumheight    = 10

logger.info("Opções globais carregadas com sucesso.")

