-- nvim/lua/keymaps/which-key/init.lua
-- Entry point for which-key keymap registrations.
local M_wk_init = {}

-- Attempt to load your core.debug module to get the logger
local core_debug_ok, core_debug = pcall(require, "core.debug")
local logger -- This will be the logger object for this module

if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("keymaps.which-key.init")
  logger.info("Successfully obtained logger from core.debug.")
else
  local reason = "Unknown reason for logger failure."
  if not core_debug_ok then
    reason = "Failed to load core.debug module. Error: " .. tostring(core_debug)
  elseif not core_debug then
    reason = "'core.debug' module loaded as nil."
  elseif not core_debug.get_logger then
    reason = "'get_logger' function not found in 'core.debug' module."
  end
  vim.notify("ERROR [keymaps.which-key.init]: Debug logger setup failed. " .. reason .. ". Using fallback print logger.", vim.log.levels.ERROR)
  logger = {
    info = function(...) local args = {...}; print("INFO [WK_INIT_FB]:", unpack(args)) end,
    error = function(...) local args = {...}; print("ERROR [WK_INIT_FB]:", unpack(args)) end,
    warn = function(...) local args = {...}; print("WARN [WK_INIT_FB]:", unpack(args)) end,
    debug = function(...) local args = {...}; print("DEBUG [WK_INIT_FB]:", unpack(args)) end,
  }
  logger.warn("Using fallback print logger due to issues with core.debug.")
end

-- List of submodules to be loaded from lua/keymaps/which-key/
-- Ensure these filenames match exactly (without .lua)
local submodules = {
  "bufferline",  
  "explorer",  -- For nvim-tree keymaps
  "lsp",
  "telescope", -- For Telescope related which-key entries
  "trouble",
}

function M_wk_init.setup_all_mappings(wk_instance)
  logger.info("Initiating setup_all_mappings for which-key keymaps...")

  if not wk_instance then
    logger.error("which-key instance (wk_instance) not provided to setup_all_mappings. Skipping.")
    return
  end

  logger.info("Loading all which-key keymap submodules specified in init.lua...")

  for _, submodule_name in ipairs(submodules) do
    local submodule_path = "keymaps.which-key." .. submodule_name
    logger.debug("Attempting to load submodule: " .. submodule_path)

    local load_ok, submodule_module = pcall(require, submodule_path)

    if load_ok and submodule_module then
      if type(submodule_module) == "table" then
        if type(submodule_module.register) == "function" then
          logger.info("Attempting to register mappings from submodule: " .. submodule_name)
          local submodule_logger
          if core_debug_ok and core_debug and core_debug.get_logger then
            submodule_logger = core_debug.get_logger("keymaps.which-key." .. submodule_name)
          else
            submodule_logger = logger -- Fallback to the init logger or print logger
          end

          local reg_ok, err = pcall(submodule_module.register, wk_instance, submodule_logger) -- Pass logger
          if reg_ok then
            logger.info("Mappings successfully registered from submodule: " .. submodule_name)
          else
            logger.error("Error registering mappings from submodule " .. submodule_name .. ": " .. tostring(err))
          end
        else
          logger.warn("Submodule " .. submodule_name .. " does not have a 'register' function. Skipping registration.")
        end
      else
        logger.error("Submodule " .. submodule_name .. " loaded but is not a table (type: " .. type(submodule_module) .. "). Skipping.")
      end
    else
      logger.error("Failed to load submodule " .. submodule_name .. ". Error: " .. tostring(submodule_module))
    end
  end

  logger.info("All specified which-key keymap submodules processed.")
end

return M_wk_init

