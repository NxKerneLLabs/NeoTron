-- Componentes reutilizáveis de UI (sidebar, modal, footer)
local Components = {}

-- Insere um item no painel principal do MCP
function Components.add_to_panel(win, text)
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, {text})
end

-- Simula um componente de loading (exibição de status)
function Components.show_loading(win, message)
  -- Atualiza linha de status enquanto aguarda resposta
  vim.api.nvim_buf_set_lines(vim.api.nvim_win_get_buf(win), 1, 2, false, {message})
end

return Components

