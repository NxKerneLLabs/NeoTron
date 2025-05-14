-- nvim/lua/keymaps/which-key/terminal.lua
-- Registers ToggleTerm keybindings with which-key.nvim using the new specification.

local M = {}

function M.register(wk_instance)
  local core_debug_ok, core_debug = pcall(require, "core.debug")
  local debug_logger
  if core_debug_ok and core_debug and core_debug.get_logger then
    debug_logger = core_debug.get_logger("keymaps.terminal")
  elseif core_debug_ok and core_debug then
    debug_logger = core_debug
  else
    debug_logger = {
      info = function(msg) vim.notify("TERM_WK_KEYS INFO: " .. msg, vim.log.levels.INFO) end,
      error = function(msg) vim.notify("TERM_WK_KEYS ERROR: " .. msg, vim.log.levels.ERROR) end,
      warn = function(msg) vim.notify("TERM_WK_KEYS WARN: " .. msg, vim.log.levels.WARN) end,
    }
    debug_logger.warn("core.debug module not found or logger not available for keymaps/which-key/terminal.lua.")
  end

  if not wk_instance then
    debug_logger.error("which-key instance (wk_instance) not provided to Terminal keymap registration. Skipping.")
    return
  end

  local term_fns_ok, term_fns_module = pcall(require, "functions.terminal")
  if not term_fns_ok or not term_fns_module then
    -- 'term_fns_module' will contain the error message if pcall failed
    debug_logger.error("'functions.terminal' module not found or failed to load. Cannot register Terminal keymaps. Error: " .. tostring(term_fns_module))
    return
  end

  local icons_ok, icons = pcall(require, "utils.icons")
  if not icons_ok or not icons then
    debug_logger.warn("'utils.icons' module not found. Using text fallbacks for Terminal which-key names. Error: " .. tostring(icons))
    icons = { ui = {} } -- Fallback
  else
    icons.ui = icons.ui or {}
  end

  local term_icon = icons.ui.Terminal or "" -- Use a shorter name for the icon variable

  -- The group <leader>t should ideally be defined in your main which-key config
  -- e.g., in plugins/which-key.lua or keymaps/which-key/init.lua
  -- This file will then register children of that group.
  local terminal_mappings = {
    -- If <leader>t is already a group, you don't need to redefine it here.
    -- { "<leader>t", group = term_icon .. " Terminal Actions" }, -- This line might be redundant if <leader>t is already a group.

    { "<leader>tf", function() if term_fns_module.toggle_float then term_fns_module.toggle_float() else debug_logger.error("term_fns_module.toggle_float not found") end end, desc = term_icon .. " Float" },
    { "<leader>tv", function() if term_fns_module.toggle_vertical then term_fns_module.toggle_vertical() else debug_logger.error("term_fns_module.toggle_vertical not found") end end, desc = term_icon .. " Vertical" },
    { "<leader>th", function() if term_fns_module.toggle_horizontal then term_fns_module.toggle_horizontal() else debug_logger.error("term_fns_module.toggle_horizontal not found") end end, desc = term_icon .. " Horizontal" },
    { "<leader>tt", function() if term_fns_module.toggle_tab then term_fns_module.toggle_tab() else debug_logger.error("term_fns_module.toggle_tab not found") end end, desc = term_icon .. " Tab" },
    { "<leader>ts", function() if term_fns_module.send_current_line then term_fns_module.send_current_line() else debug_logger.error("term_fns_module.send_current_line not found") end end, desc = "Send Line", mode = "n" },
    { "<leader>tS", function() if term_fns_module.send_visual_selection then term_fns_module.send_visual_selection() else debug_logger.error("term_fns_module.send_visual_selection not found") end end, desc = "Send Selection", mode = "v" }, -- Changed to <leader>tS to avoid conflict with normal mode <leader>ts
  }

  if wk_instance and wk_instance.register then
    local reg_ok, reg_err = pcall(wk_instance.register, terminal_mappings)
    if reg_ok then
      debug_logger.info("ToggleTerm keymaps registered with which-key.")
    else
      debug_logger.error("Failed to register ToggleTerm keymaps with which-key: " .. tostring(reg_err))
    end
  else
    debug_logger.error("wk_instance.register function is not available.")
  end
end

return M

