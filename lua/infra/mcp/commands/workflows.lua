-- Encadeamento de ações comuns (workflows) do MCP
local Workflows = {}

-- Exemplo de workflow: refatorar e, depois, testar
function Workflows.refactor_and_test()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local code = table.concat(lines, "\n")
  local refactored = require("infra.mcp.agents").execute("refactor", code)
  if refactored then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(refactored, "\n"))
    vim.notify("Código refatorado, executando testes...", vim.log.levels.INFO)
    -- Exemplo: executar testes (pode usar terminal integrado)
    vim.cmd("!pytest")  -- supondo um projeto Python
  else
    vim.notify("Refatoração falhou", vim.log.levels.ERROR)
  end
end

return Workflows

