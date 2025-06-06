-- nvim/lua/core/debug/events.lua
-- Tools for tracking general Neovim events and autocommands

local logger = require("core.debug.logger")

local M = {}

function M.track_events(events, namespace)
  events = events or { "BufEnter", "BufLeave", "WinEnter", "WinLeave", "CmdlineEnter", "CmdlineLeave" }
  namespace = namespace or "global"
  for _, event in ipairs(events) do
    vim.api.nvim_create_autocmd(event, {
      callback = function(args)
        logger.info(namespace, string.format("Event '%s' triggered: %s", event, vim.inspect(args)))
      end,
      desc = string.format("Debug tracking for %s", event),
    })
  end
  logger.info(namespace, string.format("Tracking events: %s", table.concat(events, ", ")))
end

return M
