-- Caminho: lua/ui/notify.lua
-- Este arquivo deve retornar uma LISTA de especificações de plugins para lazy.nvim

-- Obtain a namespaced logger from core.debug for this module file itself
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("ui.notify_spec") -- Logger for this spec file
else
  logger = { -- Fallback básico
    info = function(msg) vim.notify("UI_NOTIFY_SPEC INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("UI_NOTIFY_SPEC ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("UI_NOTIFY_SPEC WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("UI_NOTIFY_SPEC DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  elseif not core_debug.get_logger then
     logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

return {
  -- Notificações elegantes com nvim-notify
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy", -- Load on first notification or explicitly
    -- You can also use `init` to set vim.notify early if needed by other plugins before VeryLazy
    -- init = function()
    --   vim.notify = require("notify") -- Override early if needed
    -- end,
    config = function()
      local plugin_logger
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger = core_debug.get_logger("plugins.nvim-notify")
      else
        plugin_logger = logger -- Fallback to the file's logger
        plugin_logger.error("core.debug.get_logger not found for nvim-notify config.")
      end

      plugin_logger.info("Configuring rcarriga/nvim-notify...")

      local notify_ok, notify = pcall(require, "notify")
      if not notify_ok then
        plugin_logger.error("Failed to load 'notify' module. nvim-notify setup aborted. Error: " .. tostring(notify))
        return
      end

      local icons_utils_ok, icons_utils = pcall(require, "utils.icons")
      local notify_icons = {
          DEBUG = " ", ERROR = " ", INFO = " ", TRACE = "✎ ", WARN = " ", SUCCESS = "✓ "
      }
      if icons_utils_ok and icons_utils then
          notify_icons.DEBUG = (icons_utils.diagnostics and icons_utils.diagnostics.Debug) or notify_icons.DEBUG
          notify_icons.ERROR = (icons_utils.diagnostics and icons_utils.diagnostics.Error) or notify_icons.ERROR
          notify_icons.INFO  = (icons_utils.diagnostics and icons_utils.diagnostics.Info) or notify_icons.INFO
          notify_icons.TRACE = (icons_utils.diagnostics and icons_utils.diagnostics.Trace) or notify_icons.TRACE
          notify_icons.WARN  = (icons_utils.diagnostics and icons_utils.diagnostics.Warn) or notify_icons.WARN
          notify_icons.SUCCESS = (icons_utils.ui and icons_utils.ui.CheckboxChecked) or notify_icons.SUCCESS
          plugin_logger.debug("Custom icons loaded for nvim-notify.")
      else
          plugin_logger.warn("utils.icons not found for nvim-notify. Using default icons. Error: " .. tostring(icons_utils))
      end

      notify.setup({
        background_colour = "#1a1b26", -- Matches Tokyonight background
        fps = 30,
        icons = notify_icons,
        level = vim.log.levels.INFO, -- Minimum level to display
        minimum_width = 45,
        render = "default", -- "default", "compact", "minimal", "simple"
        stages = "slide",   -- "fade_in_slide_out", "fade", "slide", "static"
        timeout = 3000,     -- Default timeout for notifications
        top_down = true,    -- Notifications appear from the top
        max_height = function() return math.floor(vim.o.lines * 0.75) end,
        max_width = function() return math.floor(vim.o.columns * 0.75) end,
        on_open = nil,
        on_close = nil,
      })

      -- Override vim.notify to use this plugin
      vim.notify = notify
      plugin_logger.info("nvim-notify configured and vim.notify redirected.")
    end,
  },
}

