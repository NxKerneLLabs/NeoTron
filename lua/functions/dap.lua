-- nvim/lua/functions/dap.lua
-- Utility functions for Debug Adapter Protocol (DAP) interactions

local M = {}

-- Obtain a namespaced logger from core.debug
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("functions.dap")
else
  logger = { -- Fallback basic logging
    info = function(msg) vim.notify("DAP_FN INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("DAP_FN ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("DAP_FN WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("DAP_FN DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  else
    logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

-- Safely require DAP-related modules
local dap_ok, dap = pcall(require, "dap")
local dapui_ok, dapui = pcall(require, "dapui")
--local audio_ok, audio = pcall(require, "audio") -- Assuming 'audio' is your custom audio module

if not dap_ok then
  logger.error("Failed to load 'dap' module. DAP functions will be non-operational.")
end
if not dapui_ok then
  logger.warn("Failed to load 'dapui' module. DAP UI specific functions might not work as expected. Error: " .. tostring(dapui))
end
if not audio_ok then
  logger.warn("Failed to load 'audio' module. DAP functions will not play sounds. Error: " .. tostring(audio))
end

local function play_sound(sound_type)
  if audio_ok and audio and audio.play_success and sound_type == "success" then
    audio.play_success()
  elseif audio_ok and audio and audio.play_error and sound_type == "error" then
    audio.play_error()
  elseif audio_ok and audio and audio.play_action and sound_type == "action" then
     audio.play_action() -- Example for generic actions
  end
end

--- Starts or continues the current debugging session.
function M.start_continue()
  if not dap_ok then return logger.error("'dap' module not available for start_continue.") end
  logger.debug("Attempting to start or continue debugging session.")
  play_sound("success")
  dap.continue()
end

--- Runs the last used debug configuration.
function M.run_last()
  if not dap_ok then return logger.error("'dap' module not available for run_last.") end
  logger.debug("Attempting to run last debug session.")
  play_sound("success")
  dap.run_last()
end

--- Steps over the current line in the debugger.
function M.step_over()
  if not dap_ok then return logger.error("'dap' module not available for step_over.") end
  logger.debug("Executing DAP: Step Over")
  play_sound("action")
  dap.step_over()
end

--- Steps into the function call on the current line.
function M.step_into()
  if not dap_ok then return logger.error("'dap' module not available for step_into.") end
  logger.debug("Executing DAP: Step Into")
  play_sound("action")
  dap.step_into()
end

--- Steps out of the current function.
function M.step_out()
  if not dap_ok then return logger.error("'dap' module not available for step_out.") end
  logger.debug("Executing DAP: Step Out")
  play_sound("action")
  dap.step_out()
end

--- Toggles a breakpoint on the current line.
function M.toggle_breakpoint()
  if not dap_ok then return logger.error("'dap' module not available for toggle_breakpoint.") end
  logger.debug("Executing DAP: Toggle Breakpoint")
  play_sound("action")
  dap.toggle_breakpoint()
end

--- Prompts the user for a condition and sets a conditional breakpoint.
function M.set_conditional_breakpoint()
  if not dap_ok then return logger.error("'dap' module not available for set_conditional_breakpoint.") end
  logger.debug("Prompting for conditional breakpoint.")
  vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
    if condition and #condition > 0 then
      dap.set_breakpoint(condition)
      logger.info("DAP: Set conditional breakpoint. Condition: '" .. condition .. "'")
      play_sound("success")
    else
      logger.info("DAP: Conditional breakpoint not set (no condition provided).")
    end
  end)
end

--- Prompts the user for a message and sets a log point (breakpoint that logs a message).
function M.set_log_point()
  if not dap_ok then return logger.error("'dap' module not available for set_log_point.") end
  logger.debug("Prompting for log point message.")
  vim.ui.input({ prompt = "Log point message (expression): " }, function(logMessage)
    if logMessage and #logMessage > 0 then
      dap.set_breakpoint(nil, nil, logMessage)
      logger.info("DAP: Set log point. Message: '" .. logMessage .. "'")
      play_sound("success")
    else
      logger.info("DAP: Log point not set (no message provided).")
    end
  end)
end

--- Opens the DAP Read-Evaluate-Print Loop (REPL).
function M.open_repl()
  if not dap_ok then return logger.error("'dap' module not available for open_repl.") end
  logger.debug("Executing DAP: Open REPL")
  play_sound("action")
  dap.repl.open()
end

--- Toggles the visibility of the DAP UI (nvim-dap-ui).
function M.toggle_ui()
  if not dapui_ok then return logger.error("'dapui' module not available for toggle_ui.") end
  logger.debug("Executing DAP: Toggle UI")
  play_sound("action")
  dapui.toggle()
end

--- Resets the DAP session by closing the UI and terminating the debug session.
function M.reset_session()
  logger.info("Attempting to reset DAP session...")
  play_sound("action")
  if dapui_ok and dapui.status and dapui.status().open then -- Check if dapui is actually open
    dapui.close()
    logger.debug("DAP UI closed.")
  elseif dapui_ok then
     logger.debug("DAP UI was not open, no need to close.")
  else
    logger.warn("DAP: 'dapui' module not available, cannot close UI explicitly.")
  end

  if dap_ok then
    -- Check if a session is active before trying to terminate
    -- This might require checking dap.session() or similar status
    local session = dap.session()
    if session then
        logger.debug("Terminating active DAP session.")
        dap.terminate()
        dap.disconnect() -- Ensure disconnection as well
        logger.info("DAP session terminated and disconnected.")
    else
        logger.debug("No active DAP session to terminate.")
    end
  else
    logger.warn("DAP: 'dap' module not available, cannot terminate session.")
  end
end

logger.info("DAP utility functions (lua/functions/dap.lua) loaded.")
return M

