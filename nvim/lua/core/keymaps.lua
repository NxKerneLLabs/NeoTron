--- lua/core/keymaps.lua

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




