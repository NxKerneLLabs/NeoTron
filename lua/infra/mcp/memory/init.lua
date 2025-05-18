-- Persistência de sessões, buffers recentes e estados do MCP
local Memory = {
  sessions = {},
  last_buffer = nil,
}

-- Salva um log ou resposta no histórico de memória
function Memory.log(entry)
  table.insert(Memory.sessions, entry)
  -- Exemplo: escreve em arquivo de log (poderia usar stdpath('data'))
  local filepath = vim.fn.stdpath("data") .. "/mcp_history.log"
  local file = io.open(filepath, "a")
  if file then
    file:write(entry .. "\n")
    file:close()
  end
end

-- Recupera histórico completo
function Memory.get_history()
  return Memory.sessions
end

-- (Exemplo) Salva estado do último buffer trabalhado
function Memory.save_buffer(bufnr)
  Memory.last_buffer = bufnr
end

return Memory

