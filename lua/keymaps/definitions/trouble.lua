-- Caminho Sugerido: lua/keymaps/definitions/trouble.lua
-- (Anteriormente: nvim/lua/keymaps/which-key/trouble.lua)

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/Trouble] Gerando mapeamentos para Trouble...")

  local diag_icons = (icons and icons.diagnostics) or {}
  local ui_icons = (icons and icons.ui) or {}
  local lsp_icons_map = (icons and icons.lsp) or {}

  local trouble_group_icon = diag_icons.Warn          or ""
  local toggle_icon        = ui_icons.CheckboxChecked or ""
  local workspace_icon     = ui_icons.Project         or ""
  local document_icon      = ui_icons.Files           or ""
  local loclist_icon       = ui_icons.List            or ""
  local quickfix_icon      = ui_icons.Tools           or ""
  local refs_icon          = lsp_icons_map.References     or "󰌷"

  -- Estes mapeamentos incluem o prefixo <leader>x.
  -- O orquestrador deve registrar este módulo com prefix = "".
  -- O NOME do grupo <leader>x é definido em `plugins/which-key.lua`.
  local mappings = {
    { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = toggle_icon .. " Toggle Trouble" },
    { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = workspace_icon .. " Workspace Diagnostics" },
    { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = document_icon .. " Document Diagnostics" },
    { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = loclist_icon .. " Location List" },
    { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = quickfix_icon .. " Quickfix List" },
    { "<leader>xr", "<cmd>TroubleToggle lsp_references<cr>", desc = refs_icon .. " LSP References" },
  }

  logger.debug("[Defs/Trouble] Mapeamentos gerados.")
  return mappings
end

return M
