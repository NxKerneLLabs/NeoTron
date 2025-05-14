-- nvim/lua/plugins/ui.lua
-- Loads the selected theme dynamically and other UI plugin specifications.

-- Obtain a namespaced logger from core.debug
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("plugins.ui")
else
  -- Fallback basic logging if core.debug or get_logger is not available.
  logger = {
    info = function(msg) vim.notify("PLUGINS_UI INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("PLUGINS_UI ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("PLUGINS_UI WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("PLUGINS_UI DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  elseif not core_debug.get_logger then
     logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

-- Determine the theme to load
local default_theme_name = "tokyonight_theme" -- Define a clear default
local selected_theme_name = vim.g.selected_theme_name or default_theme_name
local theme_spec_module_path = "themes." .. selected_theme_name

logger.info("Attempting to load theme plugin specification from: " .. theme_spec_module_path)

local theme_plugin_specs_list = {} -- Ensure this is always a list

-- Load the theme plugin specification
local theme_status_ok, theme_specs_content = pcall(require, theme_spec_module_path)

if theme_status_ok then
  if type(theme_specs_content) == "table" then
    -- A theme spec file should return a table (single spec) or a list containing one spec.
    -- Example 1 (single spec): return { "folke/tokyonight.nvim", name = "tokyonight", ... }
    -- Example 2 (list with one spec): return { { "folke/tokyonight.nvim", name = "tokyonight", ... } }
    if theme_specs_content[1] and type(theme_specs_content[1]) == "string" then -- Single spec table: { "plugin/name", opts... }
        table.insert(theme_plugin_specs_list, theme_specs_content)
        logger.info("Theme specification for '" .. selected_theme_name .. "' loaded successfully (single spec format).")
    elseif theme_specs_content.name or type(theme_specs_content) == "string" then -- Also a single spec table or just name
        table.insert(theme_plugin_specs_list, theme_specs_content)
        logger.info("Theme specification for '" .. selected_theme_name .. "' loaded successfully (single spec table/string format).")
    elseif theme_specs_content[1] and type(theme_specs_content[1]) == "table" then -- List of specs (usually just one for a theme)
        for _, spec in ipairs(theme_specs_content) do
            if type(spec) == "table" then
                table.insert(theme_plugin_specs_list, spec)
            else
                logger.warn("Item in theme spec list from '" .. theme_spec_module_path .. "' is not a table. Ignoring item.")
            end
        end
        if #theme_plugin_specs_list > 0 then
            logger.info("Theme specifications for '" .. selected_theme_name .. "' loaded successfully (list format).")
        else
            logger.warn("Theme spec file '" .. theme_spec_module_path .. "' returned a list, but it was empty or contained no valid specs.")
        end
    else
      logger.warn("Content of '" .. theme_spec_module_path .. "' is a table, but not a recognized plugin specification format.")
    end
  else
    logger.warn("Theme specification file '" .. theme_spec_module_path .. "' did not return a table. Returned type: " .. type(theme_specs_content))
  end
else
  logger.error("Failed to load theme specification file: '" .. theme_spec_module_path .. "'. Error: " .. tostring(theme_specs_content) ..
                 ". Ensure the file exists in lua/themes/ and vim.g.selected_theme_name is correct.")
  -- Attempt to load a fallback theme if the selected one fails
  logger.info("Attempting to load fallback theme: " .. default_theme_name)
  local fallback_theme_path = "themes." .. default_theme_name
  local fallback_ok, fallback_content = pcall(require, fallback_theme_path)
  if fallback_ok and type(fallback_content) == "table" then
    if fallback_content[1] and type(fallback_content[1]) == "string" then
        table.insert(theme_plugin_specs_list, fallback_content)
    elseif fallback_content.name or type(fallback_content) == "string" then
        table.insert(theme_plugin_specs_list, fallback_content)
    elseif fallback_content[1] and type(fallback_content[1]) == "table" then
         for _, spec in ipairs(fallback_content) do table.insert(theme_plugin_specs_list, spec) end
    end
    if #theme_plugin_specs_list > 0 then
        logger.warn("Successfully loaded fallback theme: " .. default_theme_name)
        vim.g.selected_theme_name = default_theme_name -- Update global to reflect fallback
    else
        logger.error("Fallback theme '" .. default_theme_name .. "' also failed to provide valid specs.")
    end
  else
    logger.error("Failed to load fallback theme '" .. default_theme_name .. "'. Error: " .. tostring(fallback_content))
  end
end

-- List of modules expected to return plugin specifications for other UI elements.
-- These should be relative to the 'lua' directory.
local other_ui_plugin_spec_modules = {
  "ui.bufferline",     -- Expected to return specs for bufferline, lualine, etc.
  "ui.dashboard",      -- Expected to return spec for alpha-nvim or similar
  "ui.misc",           -- Expected to return specs for indent-blankline, devicons, nui, dressing
  "ui.notify",         -- Expected to return spec for nvim-notify
  -- "ui.theme" is no longer needed here as the theme is loaded dynamically above.
}

local final_ui_specs_list = {}

-- Add theme specs first to ensure colorscheme is applied early
for _, spec in ipairs(theme_plugin_specs_list) do
  table.insert(final_ui_specs_list, spec)
end
if #theme_plugin_specs_list == 0 then
    logger.error("No theme plugin specifications were loaded. UI might look unstyled.")
end

-- Load and add specs from other UI plugin modules
logger.info("Loading other UI plugin specifications...")
for _, module_name in ipairs(other_ui_plugin_spec_modules) do
  local load_ok, specs_from_module = pcall(require, module_name)
  if load_ok then
    if type(specs_from_module) == "table" then
      -- Module can return a single spec table or a list of spec tables
      if #specs_from_module > 0 and type(specs_from_module[1]) == "table" then -- List of specs
        for _, spec in ipairs(specs_from_module) do
          if type(spec) == "table" then
            table.insert(final_ui_specs_list, spec)
          else
            logger.warn("Item in '" .. module_name .. "' is not a plugin spec table. Ignoring.")
          end
        end
        logger.debug("UI plugin specs from '" .. module_name .. "' (list) loaded.")
      elseif (specs_from_module[1] ~= nil and type(specs_from_module[1]) == "string") or specs_from_module.name or type(specs_from_module) == "string" then -- Single spec
        table.insert(final_ui_specs_list, specs_from_module)
        logger.debug("UI plugin spec from '" .. module_name .. "' (single) loaded.")
      else
         logger.warn("Module '" .. module_name .. "' returned a table, but not in a recognized plugin spec format. Ignoring.")
      end
    else
      logger.warn("Module '" .. module_name .. "' did not return a table. Returned type: " .. type(specs_from_module) .. ". Ignoring.")
    end
  else
    logger.warn("Failed to load UI plugin specifications from: '" .. module_name .. "'. Error: " .. tostring(specs_from_module))
  end
end

logger.info("All UI plugin specifications collected. Total: " .. #final_ui_specs_list)
return final_ui_specs_list

