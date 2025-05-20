-- nvim/lua/plugins/ui.lua
-- Loads the selected theme dynamically and other UI plugin specifications.

-- Obtain a namespaced logger from core.debug
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.ui")) or fallback

-- Determine the theme to load
local default_theme_name = "tokyonight_theme"
local selected_theme_name = vim.g.selected_theme_name or default_theme_name
local theme_spec_module_path = "themes." .. selected_theme_name

logger.info("Attempting to load theme plugin specification from: " .. theme_spec_module_path)

local theme_plugin_specs_list = {}

local theme_status_ok, theme_specs_content = pcall(require, theme_spec_module_path)

if theme_status_ok then
  if type(theme_specs_content) == "table" then
    if theme_specs_content[1] and type(theme_specs_content[1]) == "string" then
        table.insert(theme_plugin_specs_list, theme_specs_content)
        logger.info("Theme specification for '" .. selected_theme_name .. "' loaded successfully (single spec format).")
    elseif theme_specs_content.name or type(theme_specs_content) == "string" then
        table.insert(theme_plugin_specs_list, theme_specs_content)
        logger.info("Theme specification for '" .. selected_theme_name .. "' loaded successfully (single spec table/string format).")
    elseif theme_specs_content[1] and type(theme_specs_content[1]) == "table" then
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
        vim.g.selected_theme_name = default_theme_name
    else
        logger.error("Fallback theme '" .. default_theme_name .. "' also failed to provide valid specs.")
    end
  else
    logger.error("Failed to load fallback theme '" .. default_theme_name .. "'. Error: " .. tostring(fallback_content))
  end
end

local other_ui_plugin_spec_modules = {
  "ui.bufferline",
  "ui.dashboard",
  "ui.misc",
  "ui.notify",
}

local final_ui_specs_list = {}

for _, spec in ipairs(theme_plugin_specs_list) do
  table.insert(final_ui_specs_list, spec)
end
if #theme_plugin_specs_list == 0 then
    logger.error("No theme plugin specifications were loaded. UI might look unstyled.")
end

logger.info("Loading other UI plugin specifications...")
for _, module_name in ipairs(other_ui_plugin_spec_modules) do
  local load_ok, specs_from_module = pcall(require, module_name)
  if load_ok then
    if type(specs_from_module) == "table" then
      if #specs_from_module > 0 and type(specs_from_module[1]) == "table" then
        for _, spec in ipairs(specs_from_module) do
          if type(spec) == "table" then
            table.insert(final_ui_specs_list, spec)
          else
            logger.warn("Item in '" .. module_name .. "' is not a plugin spec table. Ignoring.")
          end
        end
        logger.debug("UI plugin specs from '" .. module_name .. "' (list) loaded.")
      elseif (specs_from_module[1] ~= nil and type(specs_from_module[1]) == "string") or specs_from_module.name or type(specs_from_module) == "string" then
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

