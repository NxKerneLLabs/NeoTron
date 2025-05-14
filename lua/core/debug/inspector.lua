-- nvim/lua/core/debug/inspector.lua
-- Tools for inspecting Neovim state

local logger = require("core.debug.logger")

local M = {}

function M.inspect_state(namespace, context_msg)
  local context = context_msg or "Current"
  local buffers = vim.api.nvim_list_bufs()
  local windows = vim.api.nvim_list_wins()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  logger.info(namespace, string.format(
    "%s Neovim State: Buffers=%d, Windows=%d, CurrentBuf=%d, CurrentWin=%d",
    context, #buffers, #windows, current_buf, current_win
  ))
end

return M
