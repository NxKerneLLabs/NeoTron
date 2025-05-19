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


