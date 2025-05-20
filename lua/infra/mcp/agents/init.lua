-- Gerencia múltiplos agentes de IA
local Agents = {}
Agents.list = {}

-- Registra um agente pelo nome
function Agents.register(name, module)
  Agents.list[name] = module
end

-- Executa uma ação de um agente (ex: "copilot", "refactor", "explain")
function Agents.execute(agent_name, ...)
  local agent = Agents.list[agent_name]
  if agent and agent.run then
    return agent.run(...)
  else
    vim.notify("Agente não encontrado: " .. agent_name, vim.log.levels.ERROR)
  end
end

-- Inicializa e registra agentes padrão
function Agents.setup()
  require("infra.mcp.agents.copilot").setup()
  require("infra.mcp.agents.refactor").setup()
  require("infra.mcp.agents.explain").setup()
end

return Agents

