-- Escopo de projeto atual (nome, caminho, configurações)
local Project = {}

-- Obtém nome e diretório do projeto (pode usar Git ou cwd)
function Project.get_info()
  local path = vim.fn.getcwd()
  local name = vim.fn.fnamemodify(path, ":t")
  -- Carrega configuração específica se existir (ex: mcp_config.lua)
  local config = {}
  local ok, conf = pcall(dofile, path .. "/mcp_config.lua")
  if ok and type(conf) == "table" then
    config = conf
  end
  return {name = name, path = path, config = config}
end

return Project

