-- lua/core/debug/logger.lua
local config = require("core.debug.config")
local fallback_module = require("core.debug.fallback") -- Changed 'fallback' to 'fallback_module' for clarity

-- Cache de módulos com fallback visual
local _mod_cache = {}
local function safe_require(path)
  if _mod_cache[path] then return _mod_cache[path] end

  local ok, mod = pcall(require, path)
  if not ok then
    vim.schedule(function()
     vim.notify(" safe_require: Failed to load "..path..": "..tostring(mod), vim.log.levels.ERROR)
    end)
    _mod_cache[path] = false -- Cache failure as false
    return nil -- Explicitly return nil if pcall failed
  end
  _mod_cache[path] = mod
  return mod
end


-- Define the logger's own required level icons structure
local logger_level_icons_fallback = {
  DEBUG = "🐛", INFO = "ℹ️ ", WARN = "⚠️ ", ERROR = "💥", TRACE = "", FATAL = ""
}


local icons = safe_require("utils.icons") or {
misc = { CheckboxChecked = "✓", Warning = "⚠️ " },
levels = { DEBUG = "🐛", INFO = "ℹ️ ", WARN = "⚠️ ", ERROR = "💥" }
}

Load icons com fallback visual (This was your line 28)
local user_icons_module = safe_require("utils.icons")

Determine the icons to be used by the logger for levels (This was your line 31-37)
local actual_log_level_icons -- Declared here, initially nil
if user_icons_module and user_icons_module.levels and type(user_icons_module.levels) == "table" then
actual_log_level_icons = user_icons_module.levels
else
actual_log_level_icons = logger_level_icons_fallback -- This now uses the defined variable
end

local M = {}
local buffer = {}
local ns_colors = {} -- Mapeamento de namespaces para cores

-- Configuração padrão extendida
config = vim.tbl_deep_extend("force", {
  enabled = true,
  buffer_size = 100,
  log_file = vim.fn.stdpath("cache").."/kernel_debug.log",
  colors = {
    DEBUG = "#89B4FA",
    INFO = "#94E2D5",
    WARN = "#F9E2AF",
    ERROR = "#F38BA8"
  }
}, config or {})

-- Níveis de log com metadados
-- This table (around line 57-64) will now use the 'icons' table defined in the "TEMPORARILY MODIFY" section
local Levels = {
  DEBUG = { icon = icons.levels.DEBUG, color = config.colors.DEBUG }, -- This is around line 58
  INFO = { icon = icons.levels.INFO, color = config.colors.INFO },
  WARN = { icon = icons.levels.WARN, color = config.colors.WARN },
  ERROR = { icon = icons.levels.ERROR, color = config.colors.ERROR },
  TRACE = { icon = icons.levels.TRACE, color = "#B4BEFE" }, -- Ensure TRACE and FATAL are in icons.levels
  FATAL = { icon = icons.levels.FATAL, color = "#FAB387" }  -- Ensure TRACE and FATAL are in icons.levels
}

-- Gera cor única para cada namespace
local function get_ns_color(ns)
  if not ns_colors[ns] then
    local hash = 0
    for i = 1, #ns do hash = hash + ns:byte(i) end
    ns_colors[ns] = string.format("#%06x", (hash * 127) % 0xFFFFFF)
  end
  return ns_colors[ns]
end

-- Função de log unificada
local function log(level, ns, msg, opts)
  if not config.enabled then return end
  if not Levels[level] then -- Add a check for valid level
    vim.notify("LOGGER_ERROR: Invalid log level used in log() function: " .. tostring(level), vim.log.levels.ERROR)
    return
  end

  local entry = {
    timestamp = os.date("%H:%M:%S"),
    level = level,
    ns = ns,
    msg = msg,
    thread = opts and opts.thread or "main"
  }

  -- Formatação visual rica
  local colored_line = string.format(
    "%%#%s#%s %%#Normal#%%#%s#[%s] %%#Normal#%s",
    "KernelLC"..level,
    Levels[level].icon, -- This uses the 'Levels' table
    "KernelLCNS",
    ns,
    msg
  )

  table.insert(buffer, {
    raw = entry,
    display = colored_line
  })

  if #buffer >= config.buffer_size then M.flush() end

  vim.schedule(function()
    vim.api.nvim_echo({{colored_line}}, false, {})
  end)
end

-- Métodos públicos
function M.flush()
  local ok, file = pcall(vim.loop.fs_open, config.log_file, "a", 420)
  if not ok then return fallback_module.error("Failed to open log file") end -- Using fallback_module

  local lines = {}
  for _, entry in ipairs(buffer) do
    table.insert(lines, string.format("[%s] %s [%s] %s",
      entry.raw.timestamp,
      entry.raw.level,
      entry.raw.ns,
      entry.raw.msg))
  end

  vim.loop.fs_write(file, table.concat(lines, "\n").."\n", -1)
  vim.loop.fs_close(file)
  buffer = {}
end

function M.get_logger(ns)
  return setmetatable({}, {
    __index = function(_, level)
      return function(msg, opts)
        if Levels[level] then
          log(level, ns, msg, opts)
        else
          log("WARN", ns, "Invalid log level: "..tostring(level))
        end
      end
    end
  })
end

-- Extras úteis
function M.trace(ns, msg) log("TRACE", ns, msg) end
function M.fatal(ns, msg)
  log("FATAL", ns, msg)
  M.flush()
  error(msg)
end

-- Inicialização automática
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = M.flush,
  desc = "Garante que logs sejam salvos ao sair"
})

return M
