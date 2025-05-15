-- core/keymaps.lua
vim.g.mapleader = vim.g.mapleader or " "
vim.g.maplocalleader = vim.g.maplocalleader or " "

local opts = { noremap = true, silent = true }

local logger
local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("core.keymaps")
else
  logger = {
    info = function(msg) vim.notify("CORE_KEYMAPS INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("CORE_KEYMAPS ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("CORE_KEYMAPS WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("CORE_KEYMAPS DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  logger.warn("core.debug.logger não encontrado em core/keymaps.lua. Usando fallback com vim.notify.")
end

logger.info("Carregando keymaps centrais básicos (lua/core/keymaps.lua)...")

-- Essential keymaps (não devem ser registrados no which-key)
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>", opts)
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)
vim.keymap.set("n", "<A-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<A-Right>", ":vertical resize +2<CR>", opts)
vim.keymap.set("n", "<A-Up>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<A-Down>", ":resize -2<CR>", opts)


logger.debug("Keymaps essenciais básicos definidos.")
logger.info("Carregamento de keymaps centrais básicos concluído.")
