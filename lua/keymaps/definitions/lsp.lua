-- Caminho Sugerido: lua/keymaps/definitions/lsp.lua
-- (Anteriormente: nvim/lua/keymaps/which-key/lsp.lua)

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/LSP] Gerando mapeamentos para LSP...")

  local misc_icons = (icons and icons.misc) or {}
  local diag_icons = (icons and icons.diagnostics) or {}
  local lsp_icons_map  = (icons and icons.lsp) or {}
  local ui_icons   = (icons and icons.ui) or {}

  -- Ícones com fallbacks (usando os nomes das suas variáveis originais para consistência)
  local lsp_group_icon  = misc_icons.LSP            or ""
  local diag_float_icon = diag_icons.Info           or ""
  local diag_list_icon  = ui_icons.List             or ""
  local def_icon        = lsp_icons_map.Definition      or ui_icons.ArrowRight or ""
  local ref_icon        = lsp_icons_map.References      or "󰌷"
  local impl_icon       = lsp_icons_map.Implementation  or "IMP"
  local type_def_icon   = lsp_icons_map.TypeDefinition  or "𝙏"
  local hover_icon      = lsp_icons_map.Hover           or " Hover "
  local sig_help_icon   = lsp_icons_map.SignatureHelp   or "󰗚"
  local action_icon     = lsp_icons_map.CodeAction      or ui_icons.Lightbulb or "💡"
  local rename_icon     = lsp_icons_map.Rename          or ui_icons.Pencil or ""
  local format_icon     = lsp_icons_map.Format          or "🎨"

  -- Estes mapeamentos incluem os prefixos <leader>l e <leader>d.
  -- O orquestrador deve registrar este módulo com prefix = "".
  -- NOTA: A definição dos NOMES dos grupos <leader>l e <leader>d
  -- deve ocorrer em `plugins/which-key.lua`.
  local mappings = {
    -- LSP Actions sob <leader>l
    { "<leader>ld", function() vim.lsp.buf.definition() end, desc = def_icon .. " Definition" },
    { "<leader>lD", function() vim.lsp.buf.declaration() end, desc = def_icon .. " Declaration" },
    { "<leader>lr", function() vim.lsp.buf.references() end, desc = ref_icon .. " References" },
    { "<leader>lI", function() vim.lsp.buf.implementation() end, desc = impl_icon .. " Implementation" },
    { "<leader>lt", function() vim.lsp.buf.type_definition() end, desc = type_def_icon .. " Type Definition" },
    { "<leader>lh", function() vim.lsp.buf.hover() end, desc = hover_icon .. " Hover Info" },
    { "<leader>ls", function() vim.lsp.buf.signature_help() end, desc = sig_help_icon .. " Signature Help" },
    { "<leader>la", function() vim.lsp.buf.code_action() end, desc = action_icon .. " Code Action" },
    { "<leader>lR", function() vim.lsp.buf.rename() end, desc = rename_icon .. " Rename Symbol" },
    { "<leader>lf", function() vim.lsp.buf.format { async = true } end, desc = format_icon .. " Format Document" },

    -- Diagnostics related actions, sob <leader>d
    { "<leader>dl", "<cmd>Telescope diagnostics<cr>", desc = diag_list_icon .. " List Diagnostics (Telescope)" },
    { "<leader>df", function() vim.diagnostic.open_float() end, desc = diag_float_icon .. " Show Diagnostic Float" },
    { "<leader>dn", function() vim.diagnostic.goto_next() end, desc = (ui_icons.ArrowDown or "") .. " Next Diagnostic" },
    { "<leader>dp", function() vim.diagnostic.goto_prev() end, desc = (ui_icons.ArrowUp or "") .. " Previous Diagnostic" },
  }

  logger.debug("[Defs/LSP] Mapeamentos gerados.")
  return mappings
end

return M
