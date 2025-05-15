-- Caminho: nvim/lua/plugins/ui/bufferline.lua
-- Este arquivo retorna uma LISTA de especificações de plugins para lazy.nvim
-- Inclui akinsho/bufferline.nvim e nvim-lualine/lualine.nvim

local logger
local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("ui.bufferline_lualine_specs")
else
  logger = {
    info = function(msg) vim.notify("UI_BUF_LL_SPEC INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("UI_BUF_LL_SPEC ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("UI_BUF_LL_SPEC WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("UI_BUF_LL_SPEC DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug.logger module not found. Using fallback logger. Error: " .. tostring(core_debug))
  elseif not (core_debug and core_debug.get_logger) then
     logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

return {
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 📑 Bufferline (Abas/Buffers Visuais)                     │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "akinsho/bufferline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- For file icons
    },
    config = function()
      local plugin_logger
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger = core_debug.get_logger("plugins.bufferline")
      else
        plugin_logger = logger
        plugin_logger.error("core.debug.get_logger not found for bufferline config.")
      end

      plugin_logger.info("Configuring akinsho/bufferline.nvim...")

      local bufferline_ok, bufferline = pcall(require, "bufferline")
      if not bufferline_ok then
        plugin_logger.error("Failed to load 'bufferline' module. Bufferline setup aborted. Error: " .. tostring(bufferline))
        return
      end

      local icons_ok, icons_utils = pcall(require, "utils.icons")
      local diagnostics_icons = {}
      local buffer_icons = { close = "", modified = "●", indicator = "▎" }

      if icons_ok and icons_utils then
        diagnostics_icons = icons_utils.diagnostics or { Error = "E", Warn = "W", Info = "I", Hint = "H" }
        buffer_icons.close = (icons_utils.ui and icons_utils.ui.Close) or buffer_icons.close
        buffer_icons.modified = (icons_utils.ui and icons_utils.ui.CircleFull) or buffer_icons.modified
        buffer_icons.indicator = (icons_utils.ui and icons_utils.ui.Line) or buffer_icons.indicator
        plugin_logger.debug("Diagnostic and UI icons loaded for bufferline.")
      else
        plugin_logger.warn("Failed to load utils.icons for bufferline. Using default icons. Error: " .. tostring(icons_utils))
      end

      bufferline.setup({
        options = {
          mode = "buffers",
          style_preset = bufferline.style_preset.minimal,
          themable = true,
          numbers = "ordinal",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          indicator = { style = "icon", icon = buffer_icons.indicator },
          buffer_close_icon = buffer_icons.close,
          modified_icon = buffer_icons.modified,
          close_icon = buffer_icons.close,
          left_trunc_marker = (icons_ok and icons_utils and icons_utils.ui and icons_utils.ui.ChevronLeft) or "",
          right_trunc_marker = (icons_ok and icons_utils and icons_utils.ui and icons_utils.ui.ChevronRight) or "",
          max_name_length = 20,
          max_prefix_length = 15,
          truncate_names = true,
          tab_size = 0,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(_, _, diag)
            local s = ""
            if diag.error and diag.error > 0 then s = s .. (diagnostics_icons.Error or "E") .. diag.error .. " " end
            if diag.warning and diag.warning > 0 then s = s .. (diagnostics_icons.Warn or "W") .. diag.warning .. " " end
            if diag.info and diag.info > 0 then s = s .. (diagnostics_icons.Info or "I") .. diag.info .. " " end
            if diag.hint and diag.hint > 0 then s = s .. (diagnostics_icons.Hint or "H") .. diag.hint end
            return vim.trim(s)
          end,
          offsets = {
            { filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true },
          },
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = false,
          show_tab_indicators = true,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          separator_style = "thin",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          hover = { enabled = true, delay = 200, reveal = { "close" } },
          sort_by = "id",
        },
      })
      plugin_logger.info("Bufferline configured.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ ✨ Lualine (Elegant Statusline)                          │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local plugin_logger_ll
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger_ll = core_debug.get_logger("plugins.lualine")
      else
        plugin_logger_ll = logger
        plugin_logger_ll.error("core.debug.get_logger not found for lualine config.")
      end

      plugin_logger_ll.info("Configuring nvim-lualine/lualine.nvim...")

      local lualine_ok, lualine = pcall(require, "lualine")
      if not lualine_ok then
        plugin_logger_ll.error("Failed to load 'lualine' module. Lualine setup aborted. Error: " .. tostring(lualine))
        return
      end

      local navic_ok, nvim_navic = pcall(require, "nvim-navic")
      local navic_get_location_func = function() return "" end
      local navic_is_available_func = function() return false end

      if navic_ok and nvim_navic then
        plugin_logger_ll.debug("nvim-navic loaded for lualine integration.")
        navic_get_location_func = function() return nvim_navic.get_location({ highlight = true }) end
        navic_is_available_func = function() return nvim_navic.is_available() end
      else
        plugin_logger_ll.warn("nvim-navic not found for lualine. Breadcrumbs will not be available. Error: " .. tostring(nvim_navic))
      end
      
      local icons_ok_ll, icons_utils_ll = pcall(require, "utils.icons")
      local diag_symbols = {error=" ", warn=" ", info=" ", hint=" "}
      if icons_ok_ll and icons_utils_ll and icons_utils_ll.diagnostics then
        diag_symbols.error = (icons_utils_ll.diagnostics.Error or "") .. " "
        diag_symbols.warn  = (icons_utils_ll.diagnostics.Warn or "") .. " "
        diag_symbols.info  = (icons_utils_ll.diagnostics.Info or "") .. " "
        diag_symbols.hint  = (icons_utils_ll.diagnostics.Hint or "") .. " "
      end

      lualine.setup({
        options = {
          theme = vim.g.lualine_theme or "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "dashboard", "alpha", "NvimTree", "neo-tree" } },
          globalstatus = true,
          always_divide_middle = true,
          refresh = { statusline = 1000, tabline = 1000, winbar = 1000 },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff",
            { "diagnostics", sources = {"nvim_diagnostic"}, symbols = diag_symbols }
          },
          lualine_c = {
            { "filename", path = 1, shorting_rule = "abbr" },
            { navic_get_location_func, cond = navic_is_available_func },
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location", { "datetime", style = "%H:%M" } },
        },
        inactive_sections = {
          lualine_a = {}, lualine_b = {}, lualine_c = { "filename" },
          lualine_x = { "location" }, lualine_y = {}, lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = { "neo-tree", "lazy", "trouble", "mason", "toggleterm", "nvim-dap-ui" },
      })
      plugin_logger_ll.info("Lualine configured.")
    end,
  },
}
