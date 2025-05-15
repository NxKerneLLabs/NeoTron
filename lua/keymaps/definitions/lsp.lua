-- lua/keymaps/definitions/lsp.lua
local M = {}

local function safe_call(fn, desc, logger)
  return function()
    local ok, err = pcall(fn)
    if not ok then logger.error("[LSP] Error in '" .. desc .. "': " .. err) end
  end
end

function M.get_mappings(icons, logger)
  logger.debug("[LSP] Generating mappings...")

  local icons_map = {
    lsp = icons.misc and icons.misc.LSP or "",
    diag_float = icons.diagnostics and icons.diagnostics.Info or "",
    diag_list = icons.ui and icons.ui.List or "",
    def = icons.lsp and icons.lsp.Definition or "",
    ref = icons.lsp and icons.lsp.References or "󰌷",
    impl = icons.lsp and icons.lsp.Implementation or "IMP",
    type_def = icons.lsp and icons.lsp.TypeDefinition or "𝙏",
    hover = icons.lsp and icons.lsp.Hover or " Hover ",
    sig_help = icons.lsp and icons.lsp.SignatureHelp or "󰗚",
    action = icons.lsp and icons.lsp.CodeAction or "💡",
    rename = icons.lsp and icons.lsp.Rename or "",
    format = icons.lsp and icons.lsp.Format or "🎨",
    down = icons.ui and icons.ui.ArrowDown or "",
    up = icons.ui and icons.ui.ArrowUp or "",
  }

  return {
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
    { "<leader>dl", "<cmd>Telescope diagnostics<cr>", desc = icons_map.diag_list .. " List Diagnostics" },
    { "<leader>df", safe_call(vim.diagnostic.open_float, "Diagnostic Float", logger), desc = icons_map.diag_float .. " Show Diagnostic Float" },
    { "<leader>dn", safe_call(vim.diagnostic.goto_next, "Next Diagnostic", logger), desc = icons_map.down .. " Next Diagnostic" },
    { "<leader>dp", safe_call(vim.diagnostic.goto_prev, "Previous Diagnostic", logger), desc = icons_map.up .. " Previous Diagnostic" },
  }
end

return M
