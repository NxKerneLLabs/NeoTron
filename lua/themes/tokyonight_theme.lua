-- lua/themes/tokyonight_theme.lua
-- Retorna a especificação do plugin Tokyonight para lazy.nvim

-- Obtain a namespaced logger from core.debug for this module file itself
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug.init")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("ui.theme_spec_loader") -- Logger for this spec file
else
  logger = { -- Fallback básico
    info = function(msg) vim.notify("UI_THEME_SPEC INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("UI_THEME_SPEC ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("UI_THEME_SPEC WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("UI_THEME_SPEC DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  elseif not core_debug.get_logger then
     logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

-- Assuming this file is for "tokyonight" as per your original example:
logger.info("Defining Tokyonight theme specification (lua/themes/tokyonight_theme.lua)...")

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- Themes must be loaded early
    priority = 1000, -- High priority to load before other UI plugins
    name = "tokyonight", -- Explicit name for lazy.nvim
    config = function()
      local plugin_logger
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger = core_debug.get_logger("plugins.tokyonight")
      else
        plugin_logger = logger -- Fallback to the file's logger
        plugin_logger.error("core.debug.get_logger not found for tokyonight config.")
      end

      plugin_logger.info("Configuring folke/tokyonight.nvim...")

      local tokyonight_ok, tokyonight = pcall(require, "tokyonight")
      if not tokyonight_ok then
        plugin_logger.error("Failed to load 'tokyonight' module. Theme setup aborted. Error: " .. tostring(tokyonight))
        return
      end

      tokyonight.setup({
        style = vim.g.tokyonight_style or "night", -- "storm", "night", "moon", "day"
        light_style = "day",
        transparent = vim.g.tokyonight_transparent or false, -- Enable this to disable setting the background color
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = { bold = true },
          variables = {},
          sidebars = "dark", -- "dark", "transparent"
          floats = "dark",   -- "dark", "transparent"
        },
        sidebars = { "qf", "help", "vista_kind", "terminal", "packer", "NvimTree", "neo-tree", "Outline" }, -- List of sidebars to apply dark background theme to
        day_brightness = 0.3, -- Adjusts the brightness of the colors of the Day style
        hide_inactive_statusline = false, -- Enabling this option will hide inactive statuslines and replace them with a thin border instead.
        dim_inactive = true, -- dims inactive windows
        lualine_bold = true, -- When true, section headers in the lualine theme will be bold

        -- Custom colors and highlights
        on_colors = function(colors)
          -- Your original "home" feeling colors:
          colors.bg = vim.g.tokyonight_bg or "#1a1b26"
          colors.bg_dark = vim.g.tokyonight_bg_dark or "#16161e"
          colors.fg = vim.g.tokyonight_fg or "#c0caf5"
          colors.blue = vim.g.tokyonight_blue or "#7aa2f7"
          colors.yellow = vim.g.tokyonight_yellow or "#e0af68"
          colors.red = vim.g.tokyonight_red or "#f7768e"
          -- Add more custom colors if needed
          -- colors.hint = colors.blue
          -- colors.error = colors.red
        end,
        on_highlights = function(highlights, colors)
          highlights.CursorLine = { bg = colors.bg_dark }
          highlights.LineNr = { fg = colors.grey_fg or "#737aa2" } -- Use grey_fg if defined by theme, else fallback
          highlights.Visual = { bg = colors.blue_visual or "#2d3149" } -- Use blue_visual if defined
          -- Example: Make Telescope borders match theme
          -- highlights.TelescopeBorder = { fg = colors.blue, bg = colors.bg_dark }
          -- highlights.TelescopePromptBorder = { fg = colors.blue, bg = colors.bg_dark }
          -- highlights.TelescopeResultsBorder = { fg = colors.blue, bg = colors.bg_dark }
          -- highlights.TelescopePreviewBorder = { fg = colors.blue, bg = colors.bg_dark }
        end,
      })

      -- Apply the colorscheme
      local theme_to_apply = vim.g.selected_theme_name or "tokyonight" -- Should match the plugin name or a style
      if theme_to_apply == "tokyonight_theme" then theme_to_apply = "tokyonight" end -- Normalize if using your module name

      local cmd_status, cmd_err = pcall(vim.cmd, "colorscheme " .. theme_to_apply)
      if cmd_status then
        plugin_logger.info("Colorscheme '" .. theme_to_apply .. "' applied successfully.")
      else
        plugin_logger.error("Failed to apply colorscheme '" .. theme_to_apply .. "'. Error: " .. tostring(cmd_err))
        -- Try a very basic fallback if the chosen one fails
        pcall(vim.cmd, "colorscheme habamax")
      end
    end,
  },
}

