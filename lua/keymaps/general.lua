-- nvim/lua/keymaps/which-key/general.lua
-- Registers general purpose keybindings with which-key.nvim.

local M = {}

-- This function will be called by keymaps/which-key/init.lua
-- It expects wk_instance (from which-key) and a logger (from core.debug)
function M.register(wk_instance, logger)
  if not logger then
    print("ERROR [keymaps.which-key.general]: Logger not provided. Using fallback print.")
    logger = {
      info = function(msg) print("INFO [KWGEN_FB]: " .. msg) end,
      error = function(msg) print("ERROR [KWGEN_FB]: " .. msg) end,
      warn = function(msg) print("WARN [KWGEN_FB]: " .. msg) end,
      debug = function(msg) print("DEBUG [KWGEN_FB]: " .. msg) end,
    }
  end

  if not wk_instance then
    logger.error("which-key instance not provided. Cannot register general which-key mappings.")
    return
  end

  local icons_ok, icons = pcall(require, "utils.icons")
  if not icons_ok then
    logger.warn("'utils.icons' module not found. Using text fallbacks for General which-key names. Error: " .. tostring(icons))
    icons = { ui = {} } -- Basic fallback
  else
    icons.ui = icons.ui or {} -- Ensure ui sub-table exists
  end

  local save_icon = icons.ui.Save or ""
  local exit_icon = icons.ui.Exit or ""
  local settings_icon = icons.ui.Settings or ""
  local clear_icon = icons.ui.BoldClose or "" -- Or a specific "erase" icon

  local general_mappings = {
    -- Save
    { "<leader>w", "<cmd>write<cr>", desc = save_icon .. " Save File" },
    { "<leader>W", "<cmd>wall<cr>", desc = save_icon .. " Save All Files" },

    -- Quit/Session (assuming <leader>q is the main group defined elsewhere)
    { "<leader>qq", "<cmd>quit<cr>", desc = exit_icon .. " Quit Current Buffer" },
    { "<leader>qQ", "<cmd>qa!<cr>", desc = exit_icon .. " Quit Neovim!" },
    -- { "<leader>qs", "<cmd>mksession! ~/.config/nvim/session.vim<cr>", desc = save_icon .. " Save Session"}, -- Example
    -- { "<leader>ql", "<cmd>source ~/.config/nvim/session.vim<cr>", desc = exit_icon .. " Load Session"}, -- Example

    -- Editor Actions
    { "<leader><Esc>", "<cmd>noh<cr>", desc = clear_icon .. " Clear Search Highlight" },
    { "<leader>rc", "<cmd>e $MYVIMRC<cr>", desc = settings_icon .. " Edit Neovim Config" },
    { "<leader>rR", "<cmd>source $MYVIMRC<cr>", desc = settings_icon .. " Reload Neovim Config" }, -- Example

    -- You can add more general purpose leader mappings here
    -- Example: Toggle options
    -- { "<leader>ot", function() vim.opt.list = not vim.opt.list:get() end, desc = "Toggle List Chars" },
  }

  local register_ok, err = pcall(wk_instance.register, general_mappings)
  if not register_ok then
    logger.error("Error registering GENERAL which-key mappings: " .. tostring(err))
  else
    logger.info("General purpose which-key mappings registered.")
  end
end

return M

