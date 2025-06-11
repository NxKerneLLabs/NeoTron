-- lua/core/autocmds.lua
-- Autocommands for Neovim events

-- Try to load the debug logger if available
local logger_ok, logger = pcall(require, "core.debug.logger")
local debug_log = (logger_ok and logger.get_logger and logger.get_logger("autocmds")) or {
  info = function(m) vim.notify("[autocmds INFO] " .. m) end,
  warn = function(m) vim.notify("[autocmds WARN] " .. m) end,
  error = function(m) vim.notify("[autocmds ERROR] " .. m) end,
  debug = function(m) vim.notify("[autocmds DEBUG] " .. m) end,
}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Group for custom autocommands
local CustomGroup = augroup("CustomUserAutocmds", { clear = true })

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = CustomGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
  desc = "Remove trailing whitespace on save",
})

-- Return to last cursor position on reopen
autocmd("BufReadPost", {
  group = CustomGroup,
  pattern = "*",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Return to last cursor position on opening a file",
})

-- Highlight yanked text
autocmd("TextYankPost", {
  group = CustomGroup,
  pattern = "*",
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 }) end,
  desc = "Highlight yanked text briefly",
})

-- Toggle relative numbers depending on mode/focus
local function set_relative_number(enable)
  if vim.wo.number then vim.wo.relativenumber = enable end
end

autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = CustomGroup,
  pattern = "*",
  callback = function() set_relative_number(true) end,
  desc = "Enable relative numbers in normal mode / focused window",
})

autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = CustomGroup,
  pattern = "*",
  callback = function() set_relative_number(false) end,
  desc = "Disable relative numbers in insert mode / unfocused window",
})

-- Handle colorscheme changes
autocmd("ColorScheme", {
  group = CustomGroup,
  pattern = "*",
  callback = function()
    local theme = vim.g.colors_name or "unknown"
    debug_log.info("Colorscheme changed to: " .. theme)
  end,
  desc = "Handle UI updates on colorscheme change",
})

debug_log.info("Autocommands loaded and configured")
