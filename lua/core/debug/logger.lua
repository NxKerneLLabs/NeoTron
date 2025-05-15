-- nvim/lua/core/debug/logger.lua
-- Logger system with buffering, file rotation, compression, silent mode, and performance logging

local config = require("core.debug.config")

local M = {}
local buffer = {}
local timer = nil

-- Map log levels to string names
local level_names = {
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO]  = "INFO",
  [vim.log.levels.WARN]  = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
  [vim.log.levels.TRACE] = "TRACE",
}

-- Helper: convert level to string
local function level_to_string(level)
  return level_names[level] or string.format("LVL_%d", level or -1)
end

-- Performance tracking
local last_perf_time = vim.loop.hrtime()
local function log_perf(event)
  if config.performance_log then
    local now = vim.loop.hrtime()
    local elapsed_ms = (now - last_perf_time) / 1e6
    last_perf_time = now
    buffer[#buffer+1] = string.format("[PERF] [%s] Elapsed %.2fms\n", event, elapsed_ms)
  end
end

-- Rotate log file and optionally compress backup
local function rotate_log()
  log_perf("before_rotate")
  if not config.enabled then return end
  local stat = vim.uv.fs_stat(config.log_file)
  if stat and stat.size > config.max_file_size then
    local bak = config.log_file .. ".bak"
    pcall(vim.uv.fs_unlink, bak)
    local ok, err = vim.uv.fs_rename(config.log_file, bak)
    if not ok then
      if not config.silent_mode then
        vim.notify(string.format("[DEBUG] Rotate failed: %s", tostring(err)), vim.log.levels.ERROR)
      end
    elseif config.compress_backups then
      vim.fn.jobstart({"gzip", "-f", bak}, {detach=true})
    end
  end
  log_perf("after_rotate")
end

-- Flush buffer to file
local function flush_buffer()
  log_perf("before_flush")
  if not config.enabled or #buffer == 0 then return end
  rotate_log()
  local file, err = vim.uv.fs_open(config.log_file, "a", 420)
  if not file then
    if not config.silent_mode then
      vim.notify(string.format("[DEBUG] Flush open failed: %s", tostring(err)), vim.log.levels.ERROR)
    end
    return
  end
  local data = table.concat(buffer)
  vim.uv.fs_write(file, data, -1)
  vim.uv.fs_close(file)
  buffer = {}
  log_perf("after_flush")
end

-- Capture stacktrace
local function get_stacktrace(offset)
  offset = offset or 2
  local maxd = config.stacktrace_depth or 10
  local lines = {}
  for i = offset, offset + maxd -1 do
    local info = debug.getinfo(i, "Slnu")
    if not info then break end
    local name = info.name or info.namewhat or "<anonymous>"
    lines[#lines+1] = string.format("#%d: %s:%d in %s (%s, %d upvalues)",
      i-offset, info.short_src or "?", info.currentline or -1,
      name, info.what or "?", info.nups or 0)
  end
  return table.concat(lines, "\n")
end

-- Format log message
local function format_msg(level, ns, msg)
  local time = os.date("%Y-%m-%d %H:%M:%S")
  return string.format("[%s] [%s] [%s] %s", time, level_to_string(level), ns or "default_ns", msg)
end

-- Core log function
local function log(level, ns, msg, stack_override)
  if not config.enabled then return end
  local lvl = level or vim.log.levels.INFO
  local eff = config.namespaces[ns] or config.namespaces["default"] or config.log_level
  if lvl < eff then return end
  local base = format_msg(lvl, ns, msg)
  local text = base
  if stack_override or (lvl == vim.log.levels.ERROR and config.stacktrace_depth > 0) then
    text = text .. "\nStack:\n" .. get_stacktrace(4)
  end
  buffer[#buffer+1] = text .. "\n"
  if not config.silent_mode and lvl >= vim.log.levels.INFO then
    vim.notify(base, lvl)
  end
  if #buffer >= config.buffer_size then flush_buffer() end
end

-- Public methods
M.debug   = function(ns, msg) log(vim.log.levels.DEBUG,   ns, msg) end
M.info    = function(ns, msg) log(vim.log.levels.INFO,    ns, msg) end
M.warn    = function(ns, msg) log(vim.log.levels.WARN,    ns, msg) end
M.error   = function(ns, msg) log(vim.log.levels.ERROR,   ns, msg, true) end

-- Expose utilities
M.flush   = flush_buffer
M.rotate  = rotate_log
M.get_buffer = function() return buffer end

-- Factory
function M.get_logger(ns)
  local valid = (type(ns)=="string" and #ns>0) and ns or "unknown_ns"
  if valid=="unknown_ns" then M.warn("core.debug.logger", "Invalid namespace, using unknown_ns") end
  return {
    debug = function(m) M.debug(valid, m) end,
    info  = function(m) M.info(valid, m) end,
    warn  = function(m) M.warn(valid, m) end,
    error = function(m) M.error(valid, m) end,
  }
end

-- Timer init
local ok_t, t = pcall(vim.loop.new_timer)
if ok_t and t and config.enabled and config.flush_interval>0 then
  timer = t
  timer:start(config.flush_interval, config.flush_interval, vim.schedule_wrap(flush_buffer))
elseif not ok_t then
  vim.notify("[DEBUG] Timer init failed", vim.log.levels.ERROR)
end

-- Shutdown
function M.shutdown()
  M.info("core.debug.logger", "Shutdown: flushing logs")
  if timer then
    pcall(timer.stop, timer)
    pcall(timer.close, timer)
    timer = nil
  end
  flush_buffer()
end
vim.api.nvim_create_autocmd("VimLeavePre", {
  pattern = "*", callback = M.shutdown,
  desc = "Flush logs on exit"})

return M


