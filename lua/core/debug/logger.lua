-- lua/core/debug/logger.lua
-- Refatorado: logger modular + parser de strace com UI colorida e icons

local config = require("core.debug.config")
local fallback = require("core.debug.fallback")
-- Utility to safely require modules with caching and fallback notifications
local _mod_cache = {}
local function safe_require(path)
  if _mod_cache[path] then
    return _mod_cache[path].ok, _mod_cache[path].mod
  end
  local ok, mod = pcall(require, path)
  if not ok then
    fallback.error("Failed to load " .. path .. ": " .. tostring(mod))
  elseif type(mod) ~= "table" then
    fallback.warn("Module " .. path .. " returned " .. type(mod) .. ", expected table")
  end
  _mod_cache[path] = { ok = ok, mod = mod }
  return ok, mod
end

-- Corrected line: Remove invalid syntax and provide fallback if module load fails
local icons_ok, icons = safe_require("utils.icons")
if not icons_ok then
  icons = {} -- Fallback to empty table if module fails to load
end

local api = vim.api
local uv = vim.loop

local M = {}
local buffer      = {}
local perf_buffer = {}
local timer       = nil

-- Nomes de níveis e cor ANSI
local Level = {
  DEBUG = { name = "DEBUG", color = "\27[34m" },  -- azul
  INFO  = { name = "INFO",  color = "\27[36m" },  -- ciano
  WARN  = { name = "WARN",  color = "\27[33m" },  -- amarelo
  ERROR = { name = "ERROR", color = "\27[31m" },  -- vermelho
  TRACE = { name = "TRACE", color = "\27[35m" },  -- magenta
  FATAL = { name = "FATAL", color = "\27[41m" },  -- fundo vermelho
  FLUSH = { name = "FLUSH", color = "\27[32m" },  -- verde
}

-- Helper: level to ANSI prefix
local function color_prefix(lvl)
  return (Level[lvl] and Level[lvl].color) or ""
end

-- Logging básico
local function emit(level, ns, msg)
  if not config.enabled then return end
  local entry = string.format("[%s] [%s] [%s] %s",
    os.date("%H:%M:%S"), level, ns, msg)
  table.insert(buffer, entry)
  if #buffer >= config.buffer_size then M.flush() end
end

function M.debug(ns, msg) emit("DEBUG", ns, msg) end
function M.info(ns, msg)  emit("INFO",  ns, msg) end
function M.warn(ns, msg)  emit("WARN",  ns, msg) end
function M.error(ns, msg) emit("ERROR", ns, msg) end
function M.flush()
  table.insert(buffer, string.format("[%s] [%s] Flushing logs...", os.date("%H:%M:%S"), "FLUSH"))
  -- gravação simplificada
  local file = uv.fs_open(config.log_file), "a", 420
  if file then
    uv.fs_write(file, table.concat(buffer, "\n") .. "\n", -1)
    uv.fs_close(file)
    buffer = {}
  else
    fallback.error("Failed to open log file for flush")
  end
end

--==============================================================================
-- PARSING E RENDERIZAÇÃO DE STRACE
--==============================================================================

-- Extrai linhas de interesse de um dump de strace
function M.parse_strace(raw)
  local entries = {}
  for line in raw:gmatch("[^\n]+") do
    local ts, pid, call = line:match("(%d+:%d+:%d+)%s+<(%d+)>%s+%s*([^ ]+)%((.*)%)%s+=%s+([^ ]+)")
    if ts and pid then
      table.insert(entries, {
        ts      = ts,
        pid     = pid,
        syscall = call,
        args    = (line:match(call .. "%((.*)%)")),
        ret     = line:match("=%s+([^ ]+)%s"),
        raw     = line,
      })
    end
  end
  return entries
end

-- Renderiza com cor e icons
function M.render_strace(entries)
  local lines = {}
  -- Header
  table.insert(lines, "┌─ Strace Report ───────────────────────────────────────────────────┐")
  table.insert(lines, "| Timestamp  PID  Level  Syscall      Args                Ret     |")
  table.insert(lines, "├─────────────────────────────────────────────────────────────────┤")

  for idx, e in ipairs(entries) do
    -- determinar nível por palavras-chave
    local lvl = "INFO"
    if e.raw:find("E[A-Z]+") then lvl = "ERROR"
    elseif e.syscall == "open" or e.syscall == "close" then lvl = "FLUSH" end
    -- prefix e icon
    local icon = (icons.misc and icons.misc.CheckboxChecked) or "✔"
    local color = color_prefix(lvl)
    local reset = "\27[0m"
    local ln = string.format(" %3d %s%-8s%s %s%-10s%s %-20s %-10s %s",
      idx,
      color, lvl, reset,
      color, e.syscall or "unknown", reset,
      e.args or "",
      e.ret or "",
      icon)
    table.insert(lines, ln)
  end

  -- Footer
  table.insert(lines, "└─────────────────────────────────────────────────────────────────┘")
  -- Legend
  table.insert(lines, "Legend: " ..
    "\27[31mError\27[0m " ..
    "\27[33mWarn\27[0m " ..
    "\27[32mFlush\27[0m " ..
    "\27[36mInfo\27[0m " ..
    "\27[35mTrace\27[0m")

  return table.concat(lines, "\n")
end

-- Add a method to get a logger instance for a specific namespace
function M.get_logger(ns)
  return {
    debug = function(msg) M.debug(ns, msg) end,
    info  = function(msg) M.info(ns, msg) end,
    warn  = function(msg) M.warn(ns, msg) end,
    error = function(msg) M.error(ns, msg) end,
  }
end

return M
