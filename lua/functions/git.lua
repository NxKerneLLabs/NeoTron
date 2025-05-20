-- nvim/lua/functions/git.lua
-- Utility functions for Git interactions, primarily with Gitsigns,
-- and wrappers for Fugitive/Diffview commands.

local M = {}

-- Obtain a namespaced logger from core.debug
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("functions.git")
else
  logger = { -- Fallback basic logging
    info = function(msg) vim.notify("GIT_FN INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("GIT_FN ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("GIT_FN WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("GIT_FN DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  else
    logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

-- Safely require gitsigns
local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if not gitsigns_ok then
  logger.error("Failed to load 'gitsigns' module. Gitsigns functions will be non-operational. Error: " .. tostring(gitsigns))
end

-- Gitsigns actions
local function gitsigns_action(action_name, gitsigns_func, ...)
  if not gitsigns_ok or not gitsigns[gitsigns_func] then
    logger.error("'gitsigns' not available or function '" .. gitsigns_func .. "' missing for " .. action_name)
    return
  end
  logger.debug("Gitsigns: " .. action_name)
  local success, err = pcall(gitsigns[gitsigns_func], ...)
  if not success then
    logger.error("Error executing gitsigns." .. gitsigns_func .. ": " .. tostring(err))
  end
end

function M.stage_hunk() gitsigns_action("Staging current hunk", "stage_hunk") end
function M.reset_hunk() gitsigns_action("Resetting current hunk", "reset_hunk") end
function M.undo_stage_hunk() gitsigns_action("Undoing staged hunk", "undo_stage_hunk") end
function M.stage_buffer() gitsigns_action("Staging entire buffer", "stage_buffer") end
function M.reset_buffer() gitsigns_action("Resetting entire buffer", "reset_buffer") end
function M.preview_hunk() gitsigns_action("Previewing current hunk", "preview_hunk") end
function M.blame_line() gitsigns_action("Showing full blame for current line", "blame_line", { full = true }) end
function M.toggle_line_blame() gitsigns_action("Toggling current line blame", "toggle_current_line_blame") end
function M.diff_this() gitsigns_action("Diffing current buffer against HEAD", "diffthis") end
function M.diff_this_prev() gitsigns_action("Diffing current buffer against previous commit (~)", "diffthis", "~") end
function M.select_hunk() gitsigns_action("Selecting current hunk", "select_hunk") end

-- Fugitive / Diffview command wrappers
local function vim_cmd_action(action_name, cmd_string)
  logger.debug(action_name .. " (vim.cmd('" .. cmd_string .. "'))")
  local success, err = pcall(vim.cmd, cmd_string)
  if not success then
    logger.error("Error executing command '" .. cmd_string .. "': " .. tostring(err))
  end
end

function M.git_status() vim_cmd_action("Fugitive: Opening Git status window", "Git") end
function M.git_blame() vim_cmd_action("Fugitive: Opening Git blame window", "Git blame") end

function M.diffview_open(...)
  local args = { ... }
  local args_str = table.concat(args, " ")
  vim_cmd_action("Diffview: Opening Diffview", "DiffviewOpen " .. args_str)
end

function M.diffview_close() vim_cmd_action("Diffview: Closing Diffview", "DiffviewClose") end

function M.diffview_file_history(filepath)
  local target = filepath or "" -- If no path, diff history for current file
  local display_path = target == "" and vim.api.nvim_buf_get_name(0) or target
  logger.debug("Diffview: Opening file history for '" .. display_path .. "'.")
  local success, err = pcall(vim.cmd, "DiffviewFileHistory " .. target)
  if not success then
     logger.error("Error opening DiffviewFileHistory for '" .. display_path .. "': " .. tostring(err))
  end
end

logger.info("Git utility functions (lua/functions/git.lua) loaded.")
return M
