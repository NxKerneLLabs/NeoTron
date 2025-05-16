-- Caminho: lua/keymaps/definitions/lsp.lua

local M = {}

-- Função para chamadas seguras de funções LSP com captura de erros
local function safe_call(fn, desc, logger)
  return function()
    local ok, err = pcall(fn)
    if not ok then
      logger.error("[LSP] Error in '" .. desc .. "': " .. err)
    end
  end
end

function M.get_mappings(icons, logger)
  logger.debug("[Defs/LSP] Gerando mapeamentos para LSP...")

  -- Ícones com fallbacks (usando estrutura detalhada para robustez)
  local misc_icons = (icons and icons.misc) or {}
  local diag_icons = (icons and icons.diagnostics) or {}
  local lsp_icons_map = (icons and icons.lsp) or {}
  local ui_icons = (icons and icons.ui) or {}

  -- Ícones com fallbacks múltiplos
  local icons_map = {
    lsp = misc_icons.LSP or "",
    diag_float = diag_icons.Info or "",
    diag_list = ui_icons.List or "",
    def = lsp_icons_map.Definition or ui_icons.ArrowRight or "",
    ref = lsp_icons_map.References or "󰌷",
    impl = lsp_icons_map.Implementation or "IMP",
    type_def = lsp_icons_map.TypeDefinition or "𝙏",
    hover = lsp_icons_map.Hover or " Hover ",
    sig_help = lsp_icons_map.SignatureHelp or "󰗚",
    action = lsp_icons_map.CodeAction or ui_icons.Lightbulb or "💡",
    rename = lsp_icons_map.Rename or ui_icons.Pencil or "",
    format = lsp_icons_map.Format or "🎨",
    down = ui_icons.ArrowDown or "",
    up = ui_icons.ArrowUp or "",
  }

  -- Estes mapeamentos incluem os prefixos <leader>l e <leader>d.
  -- O orquestrador deve registrar este módulo com prefix = "".
  -- NOTA: A definição dos NOMES dos grupos <leader>l e <leader>d
  -- deve ocorrer em `plugins/which-key.lua`.
  local mappings = {
    -- LSP Actions sob <leader>l
    { "<leader>ld", safe_call(vim.lsp.buf.definition, "Definition", logger), desc = icons_map.def .. " Definition" },
    { "<leader>lD", safe_call(vim.lsp.buf.declaration, "Declaration", logger), desc = icons_map.def .. " Declaration" },
    { "<leader>lr", safe_call(vim.lsp.buf.references, "References", logger), desc = icons_map.ref .. " References" },
    { "<leader>lI", safe_call(vim.lsp.buf.implementation, "Implementation", logger), desc = icons_map.impl .. " Implementation" },
    { "<leader>lt", safe_call(vim.lsp.buf.type_definition, "Type Definition", logger), desc = icons_map.type_def .. " Type Definition" },
    { "<leader>lh", safe_call(vim.lsp.buf.hover, "Hover", logger), desc = icons_map.hover .. " Hover Info" },
    { "<leader>ls", safe_call(vim.lsp.buf.signature_help, "Signature Help", logger), desc = icons_map.sig_help .. " Signature Help" },
    { "<leader>la", safe_call(vim.lsp.buf.code_action, "Code Action", logger), desc = icons_map.action .. " Code Action" },
    { "<leader>lR", safe_call(vim.lsp.buf.rename, "Rename", logger), desc = icons_map.rename .. " Rename Symbol" },
    { "<leader>lf", safe_call(function() vim.lsp.buf.format { async = true } end, "Format", logger), desc = icons_map.format .. " Format Document" },
    -- Diagnostics related actions, sob <leader>d
    { "<leader>dl", "<cmd>Telescope diagnostics<cr>", desc = icons_map.diag_list .. " List Diagnostics (Telescope)" },
    { "<leader>df", safe_call(vim.diagnostic.open_float, "Diagnostic Float", logger), desc = icons_map.diag_float .. " Show Diagnostic Float" },
    { "<leader>dn", safe_call(vim.diagnostic.goto_next, "Next Diagnostic", logger), desc = icons_map.down .. " Next Diagnostic" },
    { "<leader>dp", safe_call(vim.diagnostic.goto_prev, "Previous Diagnostic", logger), desc = icons_map.up .. " Previous Diagnostic" },
  }

  logger.debug("[Defs/LSP] Mapeamentos gerados.")
  return mappings
end

return M
