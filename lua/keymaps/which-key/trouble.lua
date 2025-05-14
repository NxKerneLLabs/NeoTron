-- nvim/lua/keymaps/which-key/trouble.lua
-- Registers Trouble keybindings with which-key.nvim.

local M = {}

function M.register(wk_instance, logger)
  if not logger then
    print("ERROR [keymaps.which-key.trouble]: Logger not provided. Using fallback print.")
    logger = {
      info = function(msg) print("INFO [KWTRBL_FB]: " .. msg) end,
      error = function(msg) print("ERROR [KWTRBL_FB]: " .. msg) end,
      warn = function(msg) print("WARN [KWTRBL_FB]: " .. msg) end,
      debug = function(msg) print("DEBUG [KWTRBL_FB]: " .. msg) end,
    }
  end

  if not wk_instance then
    logger.error("which-key instance not provided. Cannot register Trouble keymaps.")
    return
  end

  local icons_ok, icons = pcall(require, "utils.icons")
  local trouble_group_icon = "" -- Default
  local toggle_icon = ""      -- Default toggle icon (e.g., check square)
  local workspace_icon = ""   -- Default workspace icon
  local document_icon = ""    -- Default document icon
  local loclist_icon = ""     -- Default list icon
  local quickfix_icon = ""    -- Default quickfix/tool icon
  local refs_icon = "󰌷"      -- Default references icon

  if icons_ok and icons then
    icons.diagnostics = icons.diagnostics or {}
    icons.ui = icons.ui or {}
    icons.lsp = icons.lsp or {}

    trouble_group_icon = icons.diagnostics.Warn or trouble_group_icon
    toggle_icon = icons.ui.CheckboxChecked or toggle_icon -- Or a specific toggle icon
    workspace_icon = icons.ui.Project or workspace_icon -- Or a more generic workspace icon
    document_icon = icons.ui.Files or document_icon
    loclist_icon = icons.ui.List or loclist_icon
    quickfix_icon = icons.ui.Tools or quickfix_icon
    refs_icon = icons.lsp.References or refs_icon
  else
    logger.warn("'utils.icons' module not found or failed to load. Using text/default fallbacks for Trouble which-key names. Error: " .. tostring(icons))
  end

  -- The main <leader>x group for "Trouble/Extra" should be defined in your global which-key setup.
  local trouble_mappings = {
    -- { "<leader>x", group = trouble_group_icon .. " Trouble Diagnostics" }, -- Redundant if global

    { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = toggle_icon .. " Toggle Trouble" },
    { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = workspace_icon .. " Workspace Diagnostics" },
    { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = document_icon .. " Document Diagnostics" },
    { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = loclist_icon .. " Location List" },
    { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = quickfix_icon .. " Quickfix List" },
    { "<leader>xr", "<cmd>TroubleToggle lsp_references<cr>", desc = refs_icon .. " LSP References" },
  }

  local register_ok, err = pcall(wk_instance.register, trouble_mappings)
  if not register_ok then
    logger.error("Error registering Trouble which-key mappings: " .. tostring(err))
  else
    logger.info("Trouble keymaps registered with which-key.")
  end
end

return M

