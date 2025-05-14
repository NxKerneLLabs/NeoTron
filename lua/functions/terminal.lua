-- nvim/lua/functions/terminal.lua
-- Utility functions for managing ToggleTerm terminals.

local M = {}

local core_debug_ok, core_debug = pcall(require, "core.debug")
local debug_logger
if core_debug_ok and core_debug and core_debug.get_logger then
  debug_logger = core_debug.get_logger("functions.terminal")
elseif core_debug_ok and core_debug then
  debug_logger = core_debug -- Or a specific logger function
else
  debug_logger = {
    info = function(msg) vim.notify("TERM_FNS INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("TERM_FNS ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("TERM_FNS WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("TERM_FNS DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  debug_logger.warn("core.debug module not found or logger not available for functions.terminal.")
end

local term_ok, Terminal = pcall(require, "toggleterm.terminal")

if not term_ok or not Terminal then
  debug_logger.error("Failed to load 'toggleterm.terminal'. Terminal functions will not work. Error: " .. tostring(Terminal))
  -- Define dummy functions to prevent errors if this module is loaded but toggleterm isn't
  M.toggle_float = function() debug_logger.error("ToggleTerm not loaded for toggle_float") end
  M.toggle_vertical = function() debug_logger.error("ToggleTerm not loaded for toggle_vertical") end
  M.toggle_horizontal = function() debug_logger.error("ToggleTerm not loaded for toggle_horizontal") end
  M.toggle_tab = function() debug_logger.error("ToggleTerm not loaded for toggle_tab") end
  M.send_current_line = function() debug_logger.error("ToggleTerm not loaded for send_current_line") end
  M.send_visual_selection = function() debug_logger.error("ToggleTerm not loaded for send_visual_selection") end
  return M
end

local function get_terminal_instance(direction_opts, id_count)
    -- Ensure direction_opts is a table, default to float if not.
    local opts = type(direction_opts) == "table" and direction_opts or { direction = "float" }
    opts.count = id_count -- Use a specific count for reusing terminals
    -- Example: { direction = "float", count = 1 }
    -- Example: { direction = "vertical", size = 80, count = 2}
    return Terminal:new(opts)
end

--- Toggles a floating terminal.
function M.toggle_float()
  local term = get_terminal_instance({ direction = "float" }, 1)
  term:toggle()
  debug_logger.debug("Toggled float terminal (id:1).")
end

--- Toggles a vertical split terminal.
function M.toggle_vertical()
  local term = get_terminal_instance({ direction = "vertical", size = math.floor(vim.o.columns * 0.4) }, 2)
  term:toggle()
  debug_logger.debug("Toggled vertical terminal (id:2).")
end

--- Toggles a horizontal split terminal.
function M.toggle_horizontal()
  local term = get_terminal_instance({ direction = "horizontal", size = math.floor(vim.o.lines * 0.3) }, 3)
  term:toggle()
  debug_logger.debug("Toggled horizontal terminal (id:3).")
end

--- Toggles a terminal in a new tab.
function M.toggle_tab()
  local term = get_terminal_instance({ direction = "tab" }, 4)
  term:toggle()
  debug_logger.debug("Toggled tab terminal (id:4).")
end

local function get_target_terminal_for_send()
    -- Prioritize already open terminals, could be more sophisticated
    -- For now, uses a persistent float terminal (id 1) for sending commands.
    -- If you have multiple terminals open, you might want a way to select which one.
    local term_instance = get_terminal_instance({ direction = "float", hidden = true }, 1)
    if not term_instance:is_open() then
        term_instance:open()
        vim.cmd("redraw") -- Ensure UI updates if terminal was hidden
        debug_logger.debug("Opened hidden float terminal (id:1) for sending command.")
    end
    return term_instance
end

--- Sends the current line to a target terminal.
function M.send_current_line()
  local term_instance = get_target_terminal_for_send()
  if not term_instance then return end

  local line_content = vim.fn.getline(".")
  term_instance:send(line_content, false) -- false to not add <CR> automatically by send
  -- Manually send <CR> via feedkeys to Neovim's input queue for the terminal
  -- This is often more reliable for terminal interaction.
  vim.api.nvim_chan_send(term_instance.jobid, line_content .. "\r")
  debug_logger.debug("Sent current line to terminal (id:1): " .. line_content)
end

--- Sends the visual selection to a target terminal.
function M.send_visual_selection()
  local term_instance = get_target_terminal_for_send()
  if not term_instance then return end

  local _, srow, scol, _ = unpack(vim.fn.getpos("'<"))
  local _, erow, ecol, _ = unpack(vim.fn.getpos("'>"))

  if srow == 0 or erow == 0 then
    debug_logger.warn("No visual selection to send.")
    return
  end

  local lines_to_send = {}
  local original_lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)

  if srow == erow then -- Single line selection
    lines_to_send[1] = original_lines[1]:sub(scol, ecol)
  else -- Multi-line selection
    lines_to_send[1] = original_lines[1]:sub(scol)
    for i = 2, #original_lines - 1 do
      lines_to_send[#lines_to_send + 1] = original_lines[i]
    end
    lines_to_send[#lines_to_send + 1] = original_lines[#original_lines]:sub(1, ecol)
  end

  local full_command = table.concat(lines_to_send, "\n")
  vim.api.nvim_chan_send(term_instance.jobid, full_command .. "\r")

  debug_logger.debug("Sent visual selection to terminal (id:1). Content:\n" .. full_command)
  vim.cmd("normal! gv") -- Re-select visual selection
end

debug_logger.info("Terminal utility functions (lua/functions/terminal.lua) loaded.")
return M

