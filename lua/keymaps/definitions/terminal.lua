-- Caminho Sugerido: lua/keymaps/definitions/terminal.lua
-- (Anteriormente: nvim/lua/keymaps/which-key/terminal.lua)

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/Terminal] Gerando mapeamentos para Terminal (ToggleTerm)...")

  local term_fns_ok, term_fns_module = pcall(require, "functions.terminal")
  if not term_fns_ok then
    logger.error("[Defs/Terminal] 'functions.terminal' não encontrado. Erro: " .. tostring(term_fns_module))
    term_fns_module = {} -- Fallback
  end

  local ui_icons = (icons and icons.ui) or {}
  local term_icon = ui_icons.Terminal or ""

  -- Estes mapeamentos incluem o prefixo <leader>t.
  -- O orquestrador deve registrar este módulo com prefix = "".
  -- O NOME do grupo <leader>t é definido em `plugins/which-key.lua`.
  local mappings = {
    { "<leader>tf", function() if term_fns_module.toggle_float then term_fns_module.toggle_float() else logger.error("[Defs/Terminal] term_fns_module.toggle_float não encontrado") end end, desc = term_icon .. " Float" },
    { "<leader>tv", function() if term_fns_module.toggle_vertical then term_fns_module.toggle_vertical() else logger.error("[Defs/Terminal] term_fns_module.toggle_vertical não encontrado") end end, desc = term_icon .. " Vertical" },
    { "<leader>th", function() if term_fns_module.toggle_horizontal then term_fns_module.toggle_horizontal() else logger.error("[Defs/Terminal] term_fns_module.toggle_horizontal não encontrado") end end, desc = term_icon .. " Horizontal" },
    { "<leader>tt", function() if term_fns_module.toggle_tab then term_fns_module.toggle_tab() else logger.error("[Defs/Terminal] term_fns_module.toggle_tab não encontrado") end end, desc = term_icon .. " Tab" },
    { "<leader>ts", function() if term_fns_module.send_current_line then term_fns_module.send_current_line() else logger.error("[Defs/Terminal] term_fns_module.send_current_line não encontrado") end end, desc = "Send Line", mode = "n" },
    { "<leader>tS", function() if term_fns_module.send_visual_selection then term_fns_module.send_visual_selection() else logger.error("[Defs/Terminal] term_fns_module.send_visual_selection não encontrado") end end, desc = "Send Selection", mode = "v" },
  }

  logger.debug("[Defs/Terminal] Mapeamentos gerados.")
  return mappings
end

return M
