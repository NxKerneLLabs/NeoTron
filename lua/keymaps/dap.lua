-- nvim/lua/keymaps/which-key/dap.lua
-- Registers DAP keybindings with which-key.nvim using the new nested-prefix spec.

local M = {}

function M.register(wk_instance, debug_logger)
  -- Fallback logger
  if not debug_logger then
    print("ERROR [keymaps.which-key.dap]: Logger not provided. Using fallback.")
    debug_logger = {
      info  = function(msg) vim.notify("DAP_WK INFO: "  .. msg, vim.log.levels.INFO) end,
      warn  = function(msg) vim.notify("DAP_WK WARN: "  .. msg, vim.log.levels.WARN) end,
      error = function(msg) vim.notify("DAP_WK ERROR: " .. msg, vim.log.levels.ERROR) end,
    }
  end

  if not wk_instance or not wk_instance.register then
    debug_logger.error("which-key instance not provided. Cannot register DAP keymaps.")
    return
  end

  -- Load DAP functions
  local ok_dap, dap_fns = pcall(require, "functions.dap")
  if not ok_dap then
    debug_logger.error("functions.dap module not found: " .. tostring(dap_fns))
    return
  end

  -- Load icons (with fallbacks)
  local ok_icons, icons = pcall(require, "utils.icons")
  icons = ok_icons and icons or { dap = {}, misc = {}, ui = {} }
  icons.dap  = icons.dap  or {}
  icons.misc = icons.misc or {}
  icons.ui   = icons.ui   or {}

  -- Define icons
  local bp_icon    = icons.dap.Breakpoint           or "●"
  local cbp_icon   = icons.dap.BreakpointCondition  or "◆"
  local repl_icon  = icons.dap.Repl                 or "💬"
  local run_icon   = icons.dap.RunLast              or "🔁"
  local cont_icon  = icons.dap.Continue             or "▶️"
  local stop_icon  = icons.dap.Stop                 or "⏹"
  local over_icon  = icons.dap.StepOver             or "↷"
  local into_icon  = icons.dap.StepInto             or "↴"
  local out_icon   = icons.dap.StepOut              or "↰"
  local ui_icon    = icons.dap.ToggleUI or icons.ui.Dashboard or "󰒴"

  -- Mappings under <leader>d
  local mappings = {
    b = { function() dap_fns.toggle_breakpoint() end,         desc = bp_icon   .. " Toggle Breakpoint" },
    B = { function() dap_fns.set_conditional_breakpoint() end, desc = cbp_icon  .. " Conditional Breakpoint" },
    r = { function() dap_fns.open_repl() end,                  desc = repl_icon .. " Open REPL" },
    l = { function() debug_logger.warn("Run Last not implemented") end, desc = run_icon .. " Run Last (TODO)" },
    s = { function() dap_fns.start_continue() end,             desc = cont_icon .. " Start/Continue" },
    t = { function() dap_fns.reset_session() end,              desc = stop_icon .. " Stop/Reset" },
    o = { function() dap_fns.step_over() end,                  desc = over_icon .. " Step Over" },
    i = { function() dap_fns.step_into() end,                  desc = into_icon .. " Step Into" },
    u = { function() dap_fns.step_out() end,                   desc = out_icon  .. " Step Out" },
    U = { function() dap_fns.toggle_ui() end,                  desc = ui_icon   .. " Toggle UI" },
  }

  -- Register nested under <leader>d
  local ok, err = pcall(function()
    wk_instance.register(mappings, { prefix = "<leader>d" })
  end)

  if ok then
    debug_logger.info("DAP mappings registered under <leader>d")
  else
    debug_logger.error("Failed to register DAP mappings: " .. tostring(err))
  end
end

return M
