-- lua/core/autocmds.lua
-- Comandos automáticos para eventos no Neovim

local debug = require("core.debug") -- Declarar dependências usadas no módulo

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Grupo para comandos personalizados
-- 'clear = true' é importante para evitar duplicação de autocomandos ao recarregar configs
local CustomGroup = augroup("CustomUserAutocmds", { clear = true }) -- Renomeado para clareza

-- Remove espaços em branco extras no final da linha ao salvar
autocmd("BufWritePre", {
  group = CustomGroup,
  pattern = "*", -- Aplica a todos os tipos de arquivo
  command = [[%s/\s\+$//e]], -- Expressão regular para remover espaços no final
  desc = "Remove trailing whitespace on save",
})

-- Volta para a última posição do cursor ao reabrir um arquivo
autocmd("BufReadPost", {
  group = CustomGroup,
  pattern = "*",
  callback = function(args)
    -- Verifica se o buffer tem um marcador de última posição '"' (last position)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    -- Garante que a linha do marcador é válida e está dentro dos limites do buffer
    if mark[1] > 0 and mark[1] <= line_count then
      -- Tenta restaurar a posição do cursor de forma segura
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Return to last cursor position on opening a file",
})

-- Destaca o texto copiado (yanked) por um breve momento
autocmd("TextYankPost", {
  group = CustomGroup,
  pattern = "*",
  callback = function()
    -- Usa o highlight 'IncSearch' (geralmente bem visível) por 200ms
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight yanked text briefly",
})

-- Configuração para números de linha relativos dinamicamente
-- Habilita números relativos ao entrar no modo Normal ou ganhar foco
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = CustomGroup,
  pattern = "*",
  callback = function()
    if vim.wo.number then -- Só ativa se os números de linha estiverem habilitados
      vim.opt.relativenumber = true
    end
  end,
  desc = "Enable relative numbers in normal mode / focused window",
})

-- Desabilita números relativos ao sair do modo Normal ou perder foco
autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = CustomGroup,
  pattern = "*",
  callback = function()
    if vim.wo.number then
      vim.opt.relativenumber = false
    end
  end,
  desc = "Disable relative numbers in insert mode / unfocused window",
})

-- Auto-salva todos os buffers modificados ao sair do Neovim ou perder foco (opcional)
-- Descomente as linhas abaixo se desejar esta funcionalidade.
-- Cuidado: pode ser intrusivo para alguns fluxos de trabalho.
-- autocmd({ "BufLeave", "FocusLost" }, {
--   group = CustomGroup,
--   pattern = "*", -- Aplica a todos os buffers
--   nested = true, -- Permite que autocomandos aninhados sejam disparados (ex: format on save)
--   command = "silent! wall", -- Salva todos os buffers abertos e modificados silenciosamente
--   desc = "Auto-save all modified buffers on focus lost or buffer leave",
-- })

-- Autocomando para lidar com mudanças de tema (ex: para Lualine)
autocmd("ColorScheme", {
  group = CustomGroup, -- Adicionado ao mesmo grupo para consistência
  pattern = "*",
  callback = function()
    -- Esta é uma lógica de exemplo. A forma como você obtém o nome do tema
    -- e reconfigura plugins como Lualine pode variar.
    -- Muitos temas definem vim.g.colors_name.
    local current_theme = vim.g.colors_name or "desconhecido"
    debug.info("Colorscheme mudou para: " .. current_theme .. ". Plugins de UI podem precisar ser atualizados.")

    -- Exemplo para Lualine (requer que Lualine esteja carregado):
    -- local lualine_ok, lualine = pcall(require, "lualine")
    -- if lualine_ok then
    --   lualine.setup({ options = { theme = current_theme } }) -- Ou o tema específico do Lualine
    --   debug.info("Lualine theme potentially updated to: " .. current_theme)
    -- else
    --   debug.warn("Lualine não pôde ser reconfigurado na mudança de tema.")
    -- end
  end,
  desc = "Handle UI updates on colorscheme change",
})

debug.info("Comandos automáticos (lua/core/autocmds.lua) carregados e configurados!")

