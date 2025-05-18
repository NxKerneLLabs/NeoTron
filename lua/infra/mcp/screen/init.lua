-- Sistema de layout e navegação da UI MCP
local Screen = {}

-- Abre o painel principal do MCP (como um sidebar ou float)
function Screen.open_panel()
  -- Exemplo: abrir uma janela flutuante simples
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.3)
  local height = math.floor(vim.o.lines * 0.8)
  local opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = 1,
    col = 1,
    border = "single",
  }
  vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"=== MCP Control Panel ==="})
end

-- Abre um modal de input (ex: para enviar prompt)
function Screen.open_modal(prompt, on_submit)
  vim.ui.input({ prompt = prompt }, function(input)
    if input then on_submit(input) end
  end)
end

-- Exibe saída (logs, respostas) em uma janela inferior (footer)
function Screen.show_output(text)
  local buf = vim.api.nvim_create_buf(false, true)
  local height = math.floor(vim.o.lines * 0.2)
  local opts = {
    style = "minimal",
    relative = "editor",
    width = vim.o.columns,
    height = height,
    row = vim.o.lines - height,
    col = 0,
    border = "single",
  }
  vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
end

return Screen

