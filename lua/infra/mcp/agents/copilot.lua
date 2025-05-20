-- Integração com API OpenAI (Chat/Completion), comportamento de fallback incluso
local Copilot = {}

function Copilot.setup()
  -- Exemplo: registrar este agente
  local agents = require("infra.mcp.agents")
  agents.register("copilot", Copilot)
end

-- Chama a API OpenAI via curl, ou retorna fallback
function Copilot.run(prompt)
  local api_key = vim.g.openai_api_key or os.getenv("OPENAI_API_KEY")
  if not api_key then
    return nil, "Sem chave OpenAI configurada"
  end
  -- Chamada HTTP síncrona via curl (poderia ser otimizada)
  local payload = string.format(
    '{"model": "text-davinci-003", "prompt": "%s", "max_tokens": 150}',
    prompt
  )
  local cmd = string.format(
    'curl -s -X POST https://api.openai.com/v1/completions -H "Authorization: Bearer %s" -H "Content-Type: application/json" -d \'%s\'',
    api_key, payload
  )
  local result = vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    -- Parse do resultado (simplificado)
    local answer = vim.fn.json_decode(result).choices[1].text
    return answer
  else
    return nil, "Falha na comunicação com OpenAI"
  end
end

return Copilot

