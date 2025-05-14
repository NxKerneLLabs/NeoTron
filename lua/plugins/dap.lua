-- nvim/lua/plugins/dap.lua
-- Plugin specifications for DAP (Debug Adapter Protocol), UI, and virtual text.

return {
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🐞 Core DAP Functionality                                  │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "mfussenegger/nvim-dap",
    -- Load DAP early if debugging is frequent, or use `cmd` for on-demand loading.
    -- Consider `ft` (filetype) trigger if you only debug specific languages.
    event = { "BufReadPre", "BufNewFile" },
    -- cmd = { "DapContinue", "DapToggleBreakpoint", "DapStepOver", "DapStepInto", "DapStepOut", "DapTerminate" },
    dependencies = {
      "rcarriga/nvim-dap-ui",          -- UI for DAP
      "theHamsta/nvim-dap-virtual-text", -- Inline virtual text for DAP
      "nvim-neotest/nvim-nio",         -- Optional, but good for async operations, often a dep for dap-ui or adapters
      "folke/which-key.nvim",          -- For which-key integration
      "nvim-tree/nvim-web-devicons",   -- For icons in DAP signs (optional)
    },
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.dap.core")
      else
        logger = { info = function(m) print("INFO [DAP_P_Core_FB]: " .. m) end, error = function(m) print("ERROR [DAP_P_Core_FB]: " .. m) end, warn = function(m) print("WARN [DAP_P_Core_FB]: " .. m) end, debug = function(m) print("DEBUG [DAP_P_Core_FB]: " .. m) end }
        logger.error("core.debug.get_logger not found. Using fallback for nvim-dap config.")
      end

      logger.info("Configuring mfussenegger/nvim-dap...")

      local dap_ok, dap = pcall(require, "dap")
      if not dap_ok then
        logger.error("Failed to load 'dap' module. nvim-dap setup aborted. Error: " .. tostring(dap))
        return
      end

      -- Setup DAP UI listeners (dapui will be configured in its own plugin spec)
      -- It's good practice to pcall require for dapui here as well, as this config runs
      -- before dapui's own config function might have run.
      local dapui_setup_ok, dapui = pcall(require, "dapui")
      if dapui_setup_ok and dapui then
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open({}) -- Pass empty table or specific opts if needed
          logger.debug("DAP UI opened on event_initialized.")
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close({})
          logger.debug("DAP UI closed on event_terminated.")
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close({})
          logger.debug("DAP UI closed on event_exited.")
        end
      else
        logger.warn("'dapui' module not available when setting up DAP listeners for nvim-dap. UI might not auto-open/close. Error: " .. tostring(dapui))
      end

      -- Define DAP signs using icons
      local icons_ok, icons_utils = pcall(require, "utils.icons")
      local dap_icons = {}
      if icons_ok and icons_utils and icons_utils.dap then
        dap_icons = icons_utils.dap
        logger.debug("Custom DAP icons loaded from utils.icons.")
      else
        logger.warn("'utils.icons.dap' not found. Using default text for DAP signs. Error: " .. tostring(icons_utils))
      end

      vim.fn.sign_define("DapBreakpoint", { text = dap_icons.Breakpoint or "●B", texthl = "DiagnosticError", numhl = "DapBreakpoint" })
      vim.fn.sign_define("DapBreakpointCondition", { text = dap_icons.BreakpointCondition or "●C", texthl = "DiagnosticWarn", numhl = "DapBreakpointCondition" })
      vim.fn.sign_define("DapLogPoint", { text = dap_icons.LogPoint or "●L", texthl = "DiagnosticInfo", numhl = "DapLogPoint" })
      vim.fn.sign_define("DapStopped", { text = dap_icons.Stopped or "→S", texthl = "DiagnosticInfo", numhl = "DapStopped" })
      vim.fn.sign_define("DapFrame", { text = dap_icons.FrameCurrent or "→F", texthl = "DiagnosticHint", numhl = "DapFrame" })
      logger.debug("DAP signs configured.")

      -- Register DAP keymaps with which-key
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok and wk then
        local dap_keymaps_module_ok, dap_keymaps_module = pcall(require, "keymaps.which-key.dap")
        if dap_keymaps_module_ok and dap_keymaps_module and type(dap_keymaps_module.register) == "function" then
          local keymap_logger = (core_debug_ok and core_debug.get_logger) and core_debug.get_logger("keymaps.which-key.dap") or logger
          dap_keymaps_module.register(wk, keymap_logger) -- Pass logger
          logger.info("DAP keymaps successfully registered with which-key.")
        else
          logger.warn("Failed to load or register DAP keymaps from 'keymaps.which-key.dap'. Error or module structure issue: " .. tostring(dap_keymaps_module))
        end
      else
        logger.warn("'which-key' module not available. DAP keymaps for which-key skipped. Error: " .. tostring(wk))
      end

      logger.info("nvim-dap configured successfully.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🎨 DAP UI (Graphical Interface for DAP)                  │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    -- No specific event/cmd needed if nvim-dap's listeners handle opening it.
    -- If you want to manually toggle it without a DAP session active, add a cmd or keys.
    -- cmd = "DapUiToggle",
    config = function()
      local logger_ui
      local core_debug_ok_ui, core_debug_ui = pcall(require, "core.debug")
      if core_debug_ok_ui and core_debug_ui and core_debug_ui.get_logger then
        logger_ui = core_debug_ui.get_logger("plugins.dap.ui")
      else
        logger_ui = { info = function(m) print("INFO [DAPUI_P_FB]: " .. m) end, error = function(m) print("ERROR [DAPUI_P_FB]: " .. m) end, warn = function(m) print("WARN [DAPUI_P_FB]: " .. m) end, debug = function(m) print("DEBUG [DAPUI_P_FB]: " .. m) end }
        logger_ui.error("core.debug.get_logger not found for nvim-dap-ui config.")
      end

      logger_ui.info("Configuring rcarriga/nvim-dap-ui...")
      local dapui_ok, dapui = pcall(require, "dapui")
      if not dapui_ok then
        logger_ui.error("Failed to load 'dapui' module. nvim-dap-ui setup aborted. Error: " .. tostring(dapui))
        return
      end

      local icons_ok_ui, icons_utils_ui = pcall(require, "utils.icons")
      local dap_ui_icons = {}
      if icons_ok_ui and icons_utils_ui and icons_utils_ui.dap then
        dap_ui_icons = icons_utils_ui.dap
         logger_ui.debug("Custom DAP UI icons loaded from utils.icons.dap.")
      else
        logger_ui.warn("'utils.icons.dap' not found for nvim-dap-ui. Using default icons. Error: " .. tostring(icons_utils_ui))
      end

      dapui.setup({
        icons = {
          expanded = dap_ui_icons.Expanded or "▾",
          collapsed = dap_ui_icons.Collapsed or "▸",
          current_frame = dap_ui_icons.FrameCurrent or "",
        },
        mappings = {
          expand = { "E", "<CR>" }, -- Added <CR> for expanding
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = { -- Your original layout configuration
          {
            elements = {
              { id = "scopes", size = 0.30 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 0.3, -- Adjusted to be a fraction of screen width/height
            position = "left",
          },
          {
            elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
            size = 0.2, -- Adjusted to be a fraction of screen height
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "rounded",
          mappings = { close = { "q", "<Esc>" } },
        },
        windows = { indent = 1 },
        render = { max_type_length = nil, indent = 1 },
      })
      logger_ui.info("nvim-dap-ui configured.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 💬 DAP Virtual Text (Inline debug info)                  │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = { -- Using 'opts' for simple configuration
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = true,
      only_current_frame = false,
      all_frames_displayed = false,
      virt_text_pos = "eol",
      virt_text_win_col = nil, -- Let it auto-determine
    },
    config = function(_, opts_from_lazy) -- opts_from_lazy are the values from the 'opts' table above
      local logger_vt
      local core_debug_ok_vt, core_debug_vt = pcall(require, "core.debug")
      if core_debug_ok_vt and core_debug_vt and core_debug_vt.get_logger then
        logger_vt = core_debug_vt.get_logger("plugins.dap.virtual-text")
      else
        logger_vt = { info = function(m) print("INFO [DAPVT_P_FB]: " .. m) end, error = function(m) print("ERROR [DAPVT_P_FB]: " .. m) end, warn = function(m) print("WARN [DAPVT_P_FB]: " .. m) end, debug = function(m) print("DEBUG [DAPVT_P_FB]: " .. m) end }
        logger_vt.error("core.debug.get_logger not found for nvim-dap-virtual-text config.")
      end

      logger_vt.info("Configuring nvim-dap-virtual-text...")
      local dap_vt_ok, dap_vt = pcall(require, "nvim-dap-virtual-text")
      if dap_vt_ok and dap_vt then
        dap_vt.setup(opts_from_lazy)
        logger_vt.info("nvim-dap-virtual-text configured.")
      else
        logger_vt.error("Failed to load 'nvim-dap-virtual-text' module. Error: " .. tostring(dap_vt))
      end
    end,
  },
}

