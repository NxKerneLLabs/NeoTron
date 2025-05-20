-- Caminho: lua/ui/dashboard.lua
-- Este arquivo deve retornar uma LISTA de especificações de plugins para lazy.nvim

-- Obtain a namespaced logger from core.debug for this module file itself
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("ui.dashboard_spec") -- Logger for this spec file
else
  logger = { -- Fallback básico
    info = function(msg) vim.notify("UI_DASH_SPEC INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("UI_DASH_SPEC ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("UI_DASH_SPEC WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("UI_DASH_SPEC DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  elseif not core_debug.get_logger then
     logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

return {
  -- Dashboard de inicialização com alpha-nvim
  {
    "goolord/alpha-nvim",
    event = "VimEnter", -- Load when Vim is completely initialized
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- For icons on buttons
    config = function()
      local plugin_logger
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger = core_debug.get_logger("plugins.alpha-nvim")
      else
        plugin_logger = logger -- Fallback to the file's logger
        plugin_logger.error("core.debug.get_logger not found for alpha-nvim config.")
      end

      plugin_logger.info("Configuring goolord/alpha-nvim (dashboard)...")

      local alpha_ok, alpha = pcall(require, "alpha")
      if not alpha_ok then
        plugin_logger.error("Failed to load 'alpha' module. Alpha setup aborted. Error: " .. tostring(alpha))
        return
      end

      local dashboard_ok, dashboard = pcall(require, "alpha.themes.dashboard")
      if not dashboard_ok then
        plugin_logger.error("Failed to load 'alpha.themes.dashboard'. Alpha setup aborted. Error: " .. tostring(dashboard))
        return
      end
      
      local icons_ok, icons_utils = pcall(require, "utils.icons")
      local ui_icons = {}
      if icons_ok and icons_utils and icons_utils.ui then
        ui_icons = icons_utils.ui
        plugin_logger.debug("utils.icons.ui loaded for alpha-nvim dashboard.")
      else
        plugin_logger.warn("utils.icons.ui not found for alpha-nvim. Using text fallbacks for buttons. Error: " .. tostring(icons_utils))
      end

      -- Header com ASCII art
      dashboard.section.header.val = {
        "                                                                        ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ██████╗  ██████╗ ███████╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║██╔═████╗██╔═████╗██╔════╝",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║██║██╔██║██║██╔██║█████╗  ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║████╔╝██║████╔╝██║██╔══╝  ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║╚██████╔╝╚██████╔╝███████╗",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝",
        "                                                                        ",
        "                      CONFIGURAÇÃO PROFISSIONAL " .. os.date("%Y"),
        "                                                                        ",
      }
      dashboard.section.header.opts.hl = "Include" -- Example highlight group

      -- Botões de ação
      dashboard.section.buttons.val = {
        dashboard.button("f", (ui_icons.Search or "") .. "  Find File", ":Telescope find_files<CR>"),
        dashboard.button("e", (ui_icons.Plus or "") .. "  New File", ":enew <BAR> startinsert <CR>"), -- Changed :ene to :enew
        dashboard.button("p", (ui_icons.FolderOpen or "") .. "  Find Project", ":Telescope projects<CR>"),
        dashboard.button("r", (ui_icons.History or "") .. "  Recent Files", ":Telescope oldfiles<CR>"),
        dashboard.button("t", (ui_icons.Grep or "") .. "  Find Text", ":Telescope live_grep<CR>"),
        dashboard.button("c", (ui_icons.Settings or "") .. "  Configuration", ":e $MYVIMRC<CR>"),
        dashboard.button("q", (ui_icons.Exit or "") .. "  Quit Neovim", ":qa<CR>"),
      }
      dashboard.section.buttons.opts.hl = "Keyword" -- Example highlight group

      -- Rodapé
      local fortune_ok, fortune_fn = pcall(require, "alpha.fortune")
      if fortune_ok and fortune_fn then
        dashboard.section.footer.val = fortune_fn()
        plugin_logger.debug("Fortune loaded for alpha-nvim footer.")
      else
        dashboard.section.footer.val = "Bem-vindo de volta, camarada!" -- Fallback
        plugin_logger.warn("alpha.fortune not found, using default footer. Error: " .. tostring(fortune_fn))
      end
      dashboard.section.footer.opts.hl = "Type" -- Example highlight group

      -- Layout do dashboard
      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        dashboard.section.footer,
        { type = "padding", val = 1 },
      }
      dashboard.config.opts = { noremap = true, silent = true, noautocmd = true }


      alpha.setup(dashboard.config)
      plugin_logger.info("alpha-nvim (dashboard) configured successfully.")
    end,
  },
}

