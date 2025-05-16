-- ~/.config/nvim/init.lua
-- Refactored bootstrapping with unified error handling and single logger

-- Globals
vim.g.python3_host_prog    = "/usr/bin/python3"
vim.g.selected_theme_name  = "tokyonight_theme"
vim.g.mapleader            = " "
vim.g.maplocalleader       = "\\"
vim.g.editorconfig         = false

-- Bootstrap logger & guard
local function try(require_mod)
  local ok, mod = pcall(require, require_mod)
  if not ok then
    vim.notify("[init] Failed to load '" .. require_mod .. "': " .. tostring(mod), vim.log.levels.ERROR)
    return nil
  end
  return mod
end

-- Core modules
local debug       = try("core.debug")
local logger_mod  = try("core.debug.logger")

-- Simplified logger API
local logger = logger_mod and logger_mod.get_logger("init") or {
  info  = function(_, m) vim.notify("[init] INFO: " .. m, vim.log.levels.INFO) end,
  error = function(_, m) vim.notify("[init] ERROR: " .. m, vim.log.levels.ERROR) end,
}

-- Load essential settings
try("core.options") and logger.info("init", "Options loaded.")
try("core.autocmds") and logger.info("init", "Autocmds loaded.")

-- Load keymaps and forensic tools
try("core.keymaps.init") and logger.info("init", "Keymaps loaded.")
require("utils.forensic").enable()

-- Plugin manager
local lazy = try("plugins.lazy")
if not lazy then return end
logger.info("init", "lazy.nvim initialized.")

-- Which-key / mapping hint
try("plugins.definitive") and logger.info("init", "Which-key loaded.")

-- Signal ready
debug and debug.info("init", "Neovim configuration fully loaded.")
logger.info("init", "Startup complete.")
