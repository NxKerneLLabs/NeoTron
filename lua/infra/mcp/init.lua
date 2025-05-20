local MCP = {}

function MCP.setup()
  -- Inicializar memória e comandos
  require("infra.mcp.commands").setup()
  -- Registrar e configurar agentes
  require("infra.mcp.agents").setup()
  -- Opcionalmente, abrir automaticamente o painel
  -- require("infra.mcp.screen").open_panel()
end

return MCP

