local map = vim.keymap.set

map("n", "<Space>e", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)

-- Navegação rápida
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")

-- Salvar, sair
map("n", "<C-s>", ":w<CR>")
map("n", "<C-q>", ":q<CR>")

-- FZF/Telescope
map("n", "<Space>ff", ":Telescope find_files<CR>")
map("n", "<Space>fg", ":Telescope live_grep<CR>")
map("n", "<Space>fb", ":Telescope buffers<CR>")
map("n", "<Space>fh", ":Telescope help_tags<CR>")

-- Terminal
map("n", "<C-t>", ":split | terminal<CR>")

