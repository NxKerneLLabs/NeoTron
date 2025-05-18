-- Explicações de código (pedaços selecionados)
local Explain = {}

function Explain.setup()
  local agents = require("infra.mcp.agents")
  agents.register("explain", Explain)
end

-- Recebe seleção de código e pede explicação
function Explain.run(code_snippet)
  local copilot = require("infra.mcp.agents.copilot")
  local prompt = "Explique o seguinte código:\n" .. code_snippet
  local ok, explanation = pcall(copilot.run, prompt)
  if ok and explanation then
    return explanation
  else
    return "Não foi possível obter explicação."
  end
end

return Explain

