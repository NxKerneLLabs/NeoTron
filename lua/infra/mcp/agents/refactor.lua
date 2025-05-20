-- Ações de refatoração sobre seleção de código
local Refactor = {}

function Refactor.setup()
  local agents = require("infra.mcp.agents")
  agents.register("refactor", Refactor)
end

-- Recebe seleção do usuário e usa um agente de IA para sugerir refatoração
function Refactor.run(selection)
  -- Exemplo simples: reenvia ao Copilot para refatoração
  local copilot = require("infra.mcp.agents.copilot")
  local prompt = "Refatore o seguinte código: " .. selection
  local ok, result = pcall(copilot.run, prompt)
  if ok and result then
    return result
  else
    return nil, "Não foi possível refatorar"
  end
end

return Refactor

