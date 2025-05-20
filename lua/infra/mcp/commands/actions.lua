-- Ações diretas executáveis do MCP (formatar, testar, etc)
local Actions = {}

-- Formata o buffer atual (exemplo genérico)
function Actions.format_buffer()
  if vim.lsp.buf.format then
    vim.lsp.buf.format()
  else
    vim.cmd("!stylua %")  -- supondo Lua, como fallback
  end
end

-- Executa testes do projeto (exemplo)
function Actions.run_tests()
  -- Abre terminal integrado (toggleterm) e roda comando de teste
  vim.cmd("ToggleTerm direction=float")
  local term_buf = vim.api.nvim_get_current_buf()
  vim.fn.chansend(vim.b.terminal_job_id, "pytest\n")
end

-- Outros comandos: abrir painel MCP, navegar na memória, etc.
Actions.open_panel = function()
  require("infra.mcp.screen").open_panel()
end

return Actions

