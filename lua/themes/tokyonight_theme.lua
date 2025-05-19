-- lua/themes/tokyonight_theme.lua
local logger
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("ui.tokyonight.nvim")) or fallback
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    name = "tokyonight",
    config = function()
      local plugin_logger = logger_ok and logger_mod.get_logger and logger_mod.get_logger("plugins.tokyonight") or logger
      plugin_logger.info("Configuring folke/tokyonight.nvim...")

      local tokyonight_ok, tokyonight = pcall(require, "tokyonight")
      if not tokyonight_ok then
        plugin_logger.error("Failed to load 'tokyonight' module. Theme setup aborted. Error: " .. tostring(tokyonight))
        return
      end

      tokyonight.setup({
        style = vim.g.tokyonight_style or "night",
        light_style = "day",
        transparent = vim.g.tokyonight_transparent or false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = { bold = true },
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help", "vista_kind", "terminal", "packer", "NvimTree", "neo-tree", "Outline" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = true,
        lualine_bold = true,
        on_colors = function(colors)
          colors.bg = vim.g.tokyonight_bg or "#1a1b26"
          colors.bg_dark = vim.g.tokyonight_bg_dark or "#16161e"
          colors.fg = vim.g.tokyonight_fg or "#c0caf5"
          colors.blue = vim.g.tokyonight_blue or "#7aa2f7"
          colors.yellow = vim.g.tokyonight_yellow or "#e0af68"
          colors.red = vim.g.tokyonight_red or "#f7768e"
        end,
        on_highlights = function(highlights, colors)
          highlights.CursorLine = { bg = colors.bg_dark }
          highlights.LineNr = { fg = colors.grey_fg or "#737aa2" }
          highlights.Visual = { bg = colors.blue_visual or "#2d3149" }
        end,
      })

      local theme_to_apply = vim.g.selected_theme_name or "tokyonight"
      if theme_to_apply == "tokyonight_theme" then theme_to_apply = "tokyonight" end

      local cmd_status, cmd_err = pcall(vim.cmd, "colorscheme " .. theme_to_apply)
      if cmd_status then
        plugin_logger.info("Colorscheme '" .. theme_to_apply .. "' applied successfully.")
      else
        plugin_logger.error("Failed to apply colorscheme '" .. theme_to_apply .. "'. Error: " .. tostring(cmd_err))
        pcall(vim.cmd, "colorscheme habamax")
      end
    end,
  },
}
