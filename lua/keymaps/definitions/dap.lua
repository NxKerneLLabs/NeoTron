-- Caminho Sugerido: lua/keymaps/definitions/dap.lua
-- (Anteriormente: nvim/lua/keymaps/which-key/dap.lua)

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/DAP] Gerando mapeamentos para DAP...")

  local dap_fns_ok, dap_fns = pcall(require, "functions.dap")
  if not dap_fns_ok then
    logger.error("[Defs/DAP] Módulo 'functions.dap' não encontrado: " .. tostring(dap_fns))
    return {} -- Retorna tabela vazia se a dependência crucial falhar
  end

  local dap_icons = (icons and icons.dap) or {}
  local misc_icons = (icons and icons.misc) or {}
  local ui_icons = (icons and icons.ui) or {}

  local bp_icon   = dap_icons.Breakpoint          or "●"
  local cbp_icon  = dap_icons.BreakpointCondition or "◆"
  local repl_icon = dap_icons.Repl                or "💬"
  local run_icon  = dap_icons.RunLast             or "🔁"
  local cont_icon = dap_icons.Continue            or "▶️"
  local stop_icon = dap_icons.Stop                or "⏹"
  local over_icon = dap_icons.StepOver            or "↷"
  local into_icon = dap_icons.StepInto            or "↴"
  local out_icon  = dap_icons.StepOut             or "↰"
  local ui_icon   = dap_icons.ToggleUI            or ui_icons.Dashboard or "󰒴"

  -- Estes mapeamentos são para serem registrados COM o prefixo "<leader>d"
  -- pelo orquestrador. As chaves são as letras finais.
  local mappings = {
    { "b", function() dap_fns.toggle_breakpoint() end,          desc = bp_icon .. " Toggle Breakpoint" },
    { "B", function() dap_fns.set_conditional_breakpoint() end, desc = cbp_icon .. " Conditional Breakpoint" },
    { "r", function() dap_fns.open_repl() end,                  desc = repl_icon .. " Open REPL" },
    { "l", function() logger.warn("[Defs/DAP] Run Last não implementado") end, desc = run_icon .. " Run Last (TODO)" },
    { "s", function() dap_fns.start_continue() end,             desc = cont_icon .. " Start/Continue" },
    { "t", function() dap_fns.reset_session() end,              desc = stop_icon .. " Stop/Reset" },
    { "o", function() dap_fns.step_over() end,                  desc = over_icon .. " Step Over" },
    { "i", function() dap_fns.step_into() end,                  desc = into_icon .. " Step Into" },
    { "u", function() dap_fns.step_out() end,                   desc = out_icon .. " Step Out" },
    { "U", function() dap_fns.toggle_ui() end,                  desc = ui_icon .. " Toggle UI" },
  }

  logger.debug("[Defs/DAP] Mapeamentos gerados.")
  return mappings
end

return M
