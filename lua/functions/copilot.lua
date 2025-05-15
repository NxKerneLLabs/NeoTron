-- nvim/lua/functions/copilot.lua
-- Utility functions for GitHub Copilot interactions

local M = {}

-- Obtain a namespaced logger from core.debug
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("functions.copilot")
else
  logger = { -- Fallback basic logging
    info = function(msg) vim.notify("COPILOT_FN INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("COPILOT_FN ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("COPILOT_FN WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("COPILOT_FN DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  else
    logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

--- Toggles GitHub Copilot (enable/disable).
-- Assumes the Copilot plugin provides a global command or Lua API.
function M.toggle_suggestion() -- Renamed from M.toggle to be more specific to suggestion toggling
  logger.debug("Attempting to toggle Copilot suggestion status.")
  -- This command depends on how your Copilot plugin exposes this functionality.
  -- Common plugins might use:
  -- vim.cmd("Copilot toggle")
  -- Or a Lua API call:
  local copilot_plugin_ok, cp = pcall(require, "copilot")
  if copilot_plugin_ok and cp and cp.toggle then
    cp.toggle() -- Example if it has a .toggle() function
    logger.info("Copilot suggestion status toggled via Lua API.")
  elseif copilot_plugin_ok and cp and cp.suggestion and cp.suggestion.toggle then -- For zbirenbaum/copilot.lua
    cp.suggestion.toggle()
    logger.info("Copilot suggestion status toggled via cp.suggestion.toggle().")
  else
    -- Fallback to command if Lua API is not found or known
    local cmd_ok, err = pcall(vim.cmd, "Copilot toggle")
    if cmd_ok then
      logger.info("Copilot suggestion status toggled via :Copilot toggle command.")
    else
      logger.error("Failed to toggle Copilot suggestion. Neither Lua API nor :Copilot toggle command seems to work. Error: " .. tostring(err))
    end
  end
end

--- Opens the GitHub Copilot panel.
function M.panel()
  logger.debug("Attempting to open Copilot panel.")
  local copilot_plugin_ok, cp = pcall(require, "copilot")
  if copilot_plugin_ok and cp and cp.panel then
     cp.panel.toggle() -- For zbirenbaum/copilot.lua, panel often has a toggle or open
     logger.info("Copilot panel toggled/opened via Lua API.")
  else
    local cmd_ok, err = pcall(vim.cmd, "Copilot panel")
    if cmd_ok then
      logger.info("Copilot panel opened via :Copilot panel command.")
    else
      logger.error("Failed to open Copilot panel. Error: " .. tostring(err))
    end
  end
end

--- Accepts the current Copilot suggestion.
function M.accept_suggestion() -- Renamed from M.accept
  logger.debug("Attempting to accept Copilot suggestion.")
  -- This is highly dependent on the Copilot plugin being used.
  -- For zbirenbaum/copilot.lua, it's often via a keymap bound in its setup.
  -- For other plugins, it might be a specific function or command.
  local copilot_plugin_ok, cp = pcall(require, "copilot")
  if copilot_plugin_ok and cp and cp.accept then -- zbirenbaum/copilot.lua
      cp.accept()
      logger.info("Copilot suggestion accepted via cp.accept().")
  elseif vim.fn.exists("*copilot#Accept") == 1 then -- Older copilot.vim style
    logger.info("Copilot: Accepting suggestion via copilot#Accept().")
    vim.fn.feedkeys(vim.fn["copilot#Accept"](), "n") -- 'n' mode might be for specific vimscript functions
  else
    logger.warn("Copilot: No direct Lua API found to accept suggestion. Try binding to <Plug>(copilot-accept-suggestion) or similar.")
    -- As a general attempt, one might try to simulate a Tab press, but this is unreliable.
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "i", false)
  end
end

--- Cycles to the next Copilot suggestion.
function M.next_suggestion()
  logger.debug("Attempting to cycle to next Copilot suggestion.")
  -- Typically, plugins provide <Plug> mappings for this.
  local plug_mapping = "<Plug>(copilot-next-suggestion)" -- This is a guess, check your Copilot plugin's docs
  if vim.fn.maparg(plug_mapping, "i") ~= "" or vim.fn.maparg(plug_mapping, "n") ~= "" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(plug_mapping, true, false, true), "n", true) -- 'n' and 'true' to execute mapping
    logger.info("Fed keys for " .. plug_mapping)
  else
    logger.warn("No <Plug> mapping like '" .. plug_mapping .. "' found for cycling suggestions. Check Copilot plugin docs.")
  end
end

--- Cycles to the previous Copilot suggestion.
function M.prev_suggestion()
  logger.debug("Attempting to cycle to previous Copilot suggestion.")
  local plug_mapping = "<Plug>(copilot-previous-suggestion)" -- This is a guess
  if vim.fn.maparg(plug_mapping, "i") ~= "" or vim.fn.maparg(plug_mapping, "n") ~= "" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(plug_mapping, true, false, true), "n", true)
    logger.info("Fed keys for " .. plug_mapping)
  else
    logger.warn("No <Plug> mapping like '" .. plug_mapping .. "' found for cycling suggestions. Check Copilot plugin docs.")
  end
end

logger.info("GitHub Copilot utility functions (lua/functions/copilot.lua) loaded.")
return M

