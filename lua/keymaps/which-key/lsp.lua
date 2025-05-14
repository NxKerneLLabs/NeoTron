-- nvim/lua/keymaps/which-key/lsp.lua
-- Registers LSP related keybindings with which-key.nvim.

local M = {}

function M.register(wk_instance, logger)
  if not logger then
    print("ERROR [keymaps.which-key.lsp]: Logger not provided. Using fallback print.")
    logger = {
      info = function(msg) print("INFO [KWLSP_FB]: " .. msg) end,
      error = function(msg) print("ERROR [KWLSP_FB]: " .. msg) end,
      warn = function(msg) print("WARN [KWLSP_FB]: " .. msg) end,
      debug = function(msg) print("DEBUG [KWLSP_FB]: " .. msg) end,
    }
  end

  if not wk_instance then
    logger.error("which-key instance not provided. Cannot register LSP keymaps.")
    return
  end

  local icons_ok, icons = pcall(require, "utils.icons")
  -- Define default icons first
  local lsp_group_icon = ""
  local diag_float_icon = ""
  local diag_list_icon = ""
  local def_icon = ""
  local ref_icon = "󰌷"
  local impl_icon = "IMP"
  local type_def_icon = "𝙏"
  local hover_icon = " Hover "
  local sig_help_icon = "󰗚"
  local action_icon = "💡"
  local rename_icon = ""
  local format_icon = "🎨"

  if icons_ok and icons then
    icons.misc = icons.misc or {}
    icons.diagnostics = icons.diagnostics or {}
    icons.lsp = icons.lsp or {}
    icons.ui = icons.ui or {}

    lsp_group_icon = icons.misc.LSP or lsp_group_icon
    diag_float_icon = icons.diagnostics.Info or diag_float_icon
    diag_list_icon = icons.ui.List or diag_list_icon
    def_icon = icons.lsp.Definition or icons.ui.ArrowRight or def_icon
    ref_icon = icons.lsp.References or ref_icon
    impl_icon = icons.lsp.Implementation or impl_icon
    type_def_icon = icons.lsp.TypeDefinition or type_def_icon
    hover_icon = icons.lsp.Hover or hover_icon
    sig_help_icon = icons.lsp.SignatureHelp or sig_help_icon
    action_icon = icons.lsp.CodeAction or icons.ui.Lightbulb or action_icon
    rename_icon = icons.lsp.Rename or icons.ui.Pencil or rename_icon
    format_icon = icons.lsp.Format or format_icon
  else
    logger.warn("'utils.icons' module not found or failed to load. Using text/default fallbacks for LSP which-key names. Error: " .. tostring(icons))
  end

  -- The main <leader>l group for "LSP" and <leader>d for "Debug/Diagnostics"
  -- should be defined in your global which-key setup (e.g., in plugins/which-key.lua).
  local lsp_mappings = {
    -- LSP Actions under <leader>l
    -- { "<leader>l", group = lsp_group_icon .. " LSP Actions" }, -- This group definition is likely redundant if defined globally

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

    -- Diagnostics related actions, grouped under <leader>d (Debug/Diagnostics)
    -- { "<leader>d", group = (icons.diagnostics.Bug or "") .. " Debug/Diagnostics" }, -- Redundant if global

    { "<leader>dl", "<cmd>Telescope diagnostics<cr>", desc = diag_list_icon .. " List Diagnostics (Telescope)" }, -- Changed from <leader>ll to <leader>dl for consistency
    { "<leader>df", function() vim.diagnostic.open_float() end, desc = diag_float_icon .. " Show Diagnostic Float" },
    { "<leader>dn", function() vim.diagnostic.goto_next() end, desc = (icons.ui.ArrowDown or "") .. " Next Diagnostic" },
    { "<leader>dp", function() vim.diagnostic.goto_prev() end, desc = (icons.ui.ArrowUp or "") .. " Previous Diagnostic" },
    -- { "<leader>dQ", function() vim.diagnostic.setloclist() end, desc = diag_list_icon .. " Diagnostics to Loclist" }, -- Example for setloclist
  }

  local register_ok, err = pcall(wk_instance.register, lsp_mappings)
  if not register_ok then
    logger.error("Error registering LSP which-key mappings: " .. tostring(err))
  else
    logger.info("LSP keymaps registered with which-key.")
  end
end

return M

