-- nvim/lua/core/debug/init.lua
-- Entry point for the debug system, exporting public APIs

local M = {}

-- Fallback notifier
local function initial_notify(msg, level)
  vim.notify("[CORE_DEBUG_INIT] " .. msg, level or vim.log.levels.ERROR)
end

-- Module cache for safe_require
local _mod_cache = {}
local function safe_require(path)
  if _mod_cache[path] then
    return _mod_cache[path].ok, _mod_cache[path].mod
  end
  local ok, mod = pcall(require, path)
  if not ok then
    initial_notify("Failed to load " .. path .. ": " .. tostring(mod), vim.log.levels.ERROR)
  end
  _mod_cache[path] = { ok = ok, mod = mod }
  return ok, mod
end

-- Load core debug modules
local config_ok, config       = safe_require("core.debug.config")
local logger_ok, logger       = safe_require("core.debug.logger")
local profiler_ok, profiler   = safe_require("core.debug.profiler")
local wrapper_ok, wrapper     = safe_require("core.debug.wrapper")
local inspector_ok, inspector = safe_require("core.debug.inspector")
local events_ok, events       = safe_require("core.debug.events")

-- Setup logger API
if logger_ok then
  M.logger = logger.get_logger("core.debug")
else
  M.logger = logger_ok and logger or { debug = function() end, info = function() end, warn = function() end, error = function() end }
end

-- Expose logger methods
M.debug = M.logger.debug
M.info  = M.logger.info
M.warn  = M.logger.warn
M.error = M.logger.error
M.shutdown = (logger_ok and logger.shutdown) or function() initial_notify("Logger not available for shutdown.") end

-- Expose config
if config_ok then
  M.config = config
  M.update_config = config.update
else
  M.config = { enabled = false }
  M.update_config = function() initial_notify("Config module not available.") end
end

-- Utility no-op
local noop = function(fn, ...) return fn end

-- Expose wrapper, profiler, inspector, events
M.wrap_register  = (wrapper_ok and wrapper.wrap_register) or noop
M.wrap_function  = (wrapper_ok and wrapper.wrap_function) or noop
M.profile        = (profiler_ok and profiler.profile) or noop
M.inspect_state  = (inspector_ok and inspector.inspect_state) or function() M.warn("Inspector not available") end
M.track_events   = (events_ok and events.track_events) or function() M.warn("Events not available") end

-- Initialize event tracking
function M.init_events()
  if M.config.enabled and events_ok then
    M.info("core.debug.init", "Tracking global events...")
    M.track_events(nil, "global")
  elseif not M.config.enabled then
    initial_notify("Event tracking disabled via config.", vim.log.levels.INFO)
  else
    initial_notify("Event tracking not initialized.", vim.log.levels.WARN)
  end
end

-- Bootstrap
M.info("core.debug.init", "Debug system initialization start.")
M.init_events()

return M

