-- nvim/lua/functions/init.lua
-- Main entry point to access various utility function modules.
-- This file acts as a "barrel" or index for the 'functions' module.

local M_functions_init = {} -- Renamed to avoid potential global 'M' conflicts

-- Obtain a namespaced logger from core.debug
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("functions.init")
else
  logger = { -- Fallback basic logging
    info = function(msg) vim.notify("FUNCTIONS_INIT INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("FUNCTIONS_INIT ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("FUNCTIONS_INIT WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("FUNCTIONS_INIT DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  else
    logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

logger.info("Loading utility function modules...")

-- Table to hold the loaded function modules.
-- The keys here will be how you access them, e.g., require("functions").copilot
local function_modules_to_load = {
  cmp = "functions.cmp",             -- Assuming you might create this for cmp related utility functions
  copilot = "functions.copilot",
  dap = "functions.dap",
  git = "functions.git",
  telescope = "functions.telescope",
  terminal = "functions.terminal",
  -- Add other function modules here as needed, e.g.:
  -- lsp_utils = "functions.lsp_utils", -- If you have LSP helper functions
  -- custom_utils = "functions.custom_utils",
}

local all_loaded_successfully = true

for key_name, module_path in pairs(function_modules_to_load) do
  local load_ok, loaded_module = pcall(require, module_path)
  if load_ok and loaded_module then
    M_functions_init[key_name] = loaded_module
    logger.debug("Function module '" .. module_path .. "' loaded and exposed as 'functions." .. key_name .. "'.")
  else
    logger.error("Failed to load function module '" .. module_path .. "'. Error: " .. tostring(loaded_module) .. ". It will not be available under require('functions')." .. key_name)
    M_functions_init[key_name] = nil -- Explicitly set to nil to avoid errors if accessed
    all_loaded_successfully = false
  end
end

if all_loaded_successfully then
  logger.info("All listed function modules processed successfully.")
else
  logger.warn("One or more function modules failed to load. Check logs for details. Affected modules will be nil.")
end

-- Return the namespace table containing all loaded function modules.
-- This allows access like: local funcs = require("functions"); funcs.copilot.panel()
return M_functions_init

