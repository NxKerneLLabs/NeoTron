local M = {}
local logger = require("core.debug.logger")
local db = require("core.debug.dashboard")

local function get_llm()
  local ok, llm = pcall(require, "llm")
  if not ok then
    logger.warn("LLM não encontrado. Instale via :Lazy install llm.nvim")
    return nil
  end
  return llm
end

function M.analyze_error(err_msg)
  local llm = get_llm()
  if not llm then return end

  local prompt = string.format([[
    Erro no Neovim: %s
    Contexto:
    - NVim v%s
    - Plugins: %d
    - Runtime: %s
    Sugira 3 correções concisas:
    1. [Solução rápida]
    2. [Solução completa]
    3. [Solução alternativa]
  ]], err_msg, vim.version(), #vim.fn.globpath(vim.fn.stdpath("data").."/lazy/*", 0, 1), vim.fn.stdpath("config"))

  llm.ask(prompt, function(response)
    db.add_suggestion({
      type = "AI",
      text = "Soluções para: "..err_msg:sub(1, 30).."...",
      content = response,
      actions = {
        { text = "Aplicar Solução 1", cmd = "" }, -- Pode ser preenchido dinamicamente
        { text = "Copiar Todas", cmd = "" }
      }
    })
  end)
end

vim.api.nvim_create_user_command("DebugAnalyze", function(opts)
  M.analyze_error(opts.args)
end, { nargs = 1, desc = "Analisa erro com IA" })

return M

