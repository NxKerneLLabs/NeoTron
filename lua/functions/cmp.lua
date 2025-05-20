-- nvim/lua/functions/cmp.lua
-- Utility functions for nvim-cmp completion plugin

-- Safely require core.debug and nvim-cmp modules
local logger
local debug_ok, debug = pcall(require, "core.debug.logger")
if not debug_ok then
  -- Fallback basic logging if core.debug is not available
  debug = {
    info = function(msg) vim.notify("CMP INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("CMP ERROR: " .. msg, vim.log.levels.ERROR) end,
  }
  debug.error("core.debug module not found. Using fallback logger for functions/cmp.lua.")
end

local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
  debug.error("nvim-cmp module ('cmp') not found. CMP utility functions in functions/cmp.lua will not work.")
  -- Return an empty module or a module with no-op functions if cmp is critical and not found
  return {}
end

local M = {}

--- Selects the next item in the completion menu.
-- If the menu is not visible, it triggers completion.
function M.select_next()
  if not cmp_ok then return end -- Guard clause if cmp module failed to load

  if cmp.visible() then
    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
    debug.info("CMP: Selected next item.")
  else
    cmp.complete() -- Trigger completion if not visible
    debug.info("CMP: Triggered completion (menu was not visible).")
  end
end

--- Selects the previous item in the completion menu.
-- Does not trigger completion if the menu is not visible.
function M.select_prev()
  if not cmp_ok then return end

  if cmp.visible() then
    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
    debug.info("CMP: Selected previous item.")
  else
    -- Optionally, you could trigger completion here as well, or have a different behavior.
    -- For now, it does nothing if the menu isn't visible, which is a common pattern.
    debug.info("CMP: Menu not visible, select_prev did nothing.")
  end
end

--- Confirms the currently selected completion item.
-- Requires the completion menu to be visible and an item to be selected.
function M.confirm()
  if not cmp_ok then return end

  if cmp.visible() and cmp.get_selected_entry() then
    -- cmp.confirm({ select = true }) -- 'select = true' is default, makes the confirmed item the one selected.
    -- cmp.ConfirmBehavior.Replace will replace the current text with the completion item.
    -- cmp.ConfirmBehavior.Insert will insert the completion item.
    -- Default behavior is usually good.
    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
    debug.info("CMP: Confirmed selection.")
  else
    debug.info("CMP: No selection to confirm or menu not visible.")
    -- As an alternative to just logging, you could insert a <CR> if no completion is active.
    -- This would make the confirm key behave like Enter when completion isn't active.
    -- Example:
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
  end
end

--- Manually triggers the completion menu.
function M.trigger()
  if not cmp_ok then return end

  cmp.complete()
  debug.info("CMP: Manually triggered completion.")
end

-- You could add other helper functions here, for example:
-- function M.scroll_docs_forward()
--   if not cmp_ok then return end
--   if cmp.visible() then
--     cmp.scroll_docs(4)
--     debug.info("CMP: Scrolled documentation forward.")
--   end
-- end

-- function M.scroll_docs_backward()
--   if not cmp_ok then return end
--   if cmp.visible() then
--     cmp.scroll_docs(-4)
--     debug.info("CMP: Scrolled documentation backward.")
--   end
-- end

-- function M.abort()
--   if not cmp_ok then return end
--   if cmp.visible() then
--     cmp.abort()
--     debug.info("CMP: Aborted completion.")
--   end
-- end

debug.info("nvim-cmp utility functions (lua/functions/cmp.lua) loaded.")
return M

