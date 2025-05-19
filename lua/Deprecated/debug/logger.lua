-- lua/core/debug/logger.lua
local config = require("core.debug.config")
local fallback = require("core.debug.fallback")

-- Cache de módulos com fallback visual
local _mod_cache = {}
local function safe_require(path)
  if _mod_cache[path] ~= nil then return _mod_cache[path] end

  local ok, mod = pcall(require, path)
  if not ok then
    vim.schedule(function()
      vim.notify("🔧 safe_require: Failed to load " .. path .. ": " .. tostring(mod), vim.log.levels.ERROR) 
    end)
    _mod_cache[path] = false
    return nil
  end
  _mod_cache[path] = mod
  return mod
end

-- Fallback icons - always available
local fallback_icons = {
  levels = {
    DEBUG = "🐛",
    INFO = "ℹ️ ",
    WARN = "⚠️ ",
    ERROR = "💥",
    TRACE = "🔍",
    FATAL = "💀"
  },
  misc = {
    CheckboxChecked = "✓",
    Warning = "⚠️ "
  }
}

-- Load user icons with safe fallback
local user_icons = safe_require("utils.icons")
local icons = {}

-- Safely merge icons with fallback
if user_icons and type(user_icons) == "table" then
  icons.levels = (user_icons.levels and type(user_icons.levels) == "table") 
    and user_icons.levels 
    or fallback_icons.levels
  icons.misc = (user_icons.misc and type(user_icons.misc) == "table") 
    and user_icons.misc 
    or fallback_icons.misc
else
  icons = fallback_icons
end

local M = {}
local buffer = {}
local ns_colors = {}

-- Configuração padrão extendida
config = vim.tbl_deep_extend("force", {
  enabled = true,
  buffer_size = 100,
  log_file = vim.fn.stdpath("cache") .. "/kernel_debug.log",
  colors = {
    DEBUG = "#89B4FA",
    INFO = "#94E2D5",
    WARN = "#F9E2AF",
    ERROR = "#F38BA8",
    TRACE = "#B4BEFE",
    FATAL = "#FAB387"
  }
}, config or {})

-- Níveis de log com metadados
local Levels = { 
  DEBUG = { icon = icons.levels.DEBUG, color = config.colors.DEBUG },
  INFO = { icon = icons.levels.INFO, color = config.colors.INFO },
  WARN = { icon = icons.levels.WARN, color = config.colors.WARN },
  ERROR = { icon = icons.levels.ERROR, color = config.colors.ERROR },
  TRACE = { icon = icons.levels.TRACE, color = config.colors.TRACE },
  FATAL = { icon = icons.levels.FATAL, color = config.colors.FATAL }
}

-- Gera cor única para cada namespace
local function get_ns_color(ns)
  if not ns_colors[ns] then
    local hash = 0
    for i = 1, #ns do 
      hash = hash + ns:byte(i) 
    end
    ns_colors[ns] = string.format("#%06x", (hash * 127) % 0xFFFFFF)
  end
  return ns_colors[ns]
end

-- Setup highlight groups
local function setup_highlights()
  for level, meta in pairs(Levels) do
    vim.api.nvim_set_hl(0, "KernelLC" .. level, { fg = meta.color, bold = true })
  end
  vim.api.nvim_set_hl(0, "KernelLCNS", { fg = "#CDD6F4", italic = true })
end

-- Call setup on module load
vim.schedule(setup_highlights)

-- Função de log unificada
local function log(level, ns, msg, opts)
  if not config.enabled then return end
  
  -- Validate level
  if not Levels[level] then
    level = "WARN"
    msg = "Invalid log level used: " .. tostring(msg)
  end

  local entry = {
    timestamp = os.date("%H:%M:%S"),
    level = level,
    ns = ns or "unknown",
    msg = tostring(msg),
    thread = (opts and opts.thread) or "main"
  }

  -- Formatação visual rica
  local colored_line = string.format(
    "%%#%s#%s %%#KernelLCNS#[%s] %%#Normal#%s",
    "KernelLC" .. level,
    Levels[level].icon,
    entry.ns,
    entry.msg
  )

  table.insert(buffer, {
    raw = entry,
    display = colored_line
  })

  -- Auto-flush se buffer cheio
  if #buffer >= config.buffer_size then 
    M.flush() 
  end

  -- Echo imediato no Neovim (non-blocking)
  vim.schedule(function()
    pcall(vim.api.nvim_echo, {{colored_line}}, false, {})
  end)
end

-- Métodos públicos
function M.flush()
  if #buffer == 0 then return end
  
  local ok, file = pcall(vim.loop.fs_open, config.log_file, "a", 420)
  if not ok or not file then 
    -- Use fallback if available, otherwise silent fail
    if fallback and fallback.error then
      fallback.error("Failed to open log file: " .. config.log_file)
    end
    return 
  end

  local lines = {}
  for _, entry in ipairs(buffer) do
    table.insert(lines, string.format("[%s] %-5s [%s] %s",
      entry.raw.timestamp,
      entry.raw.level,
      entry.raw.ns,
      entry.raw.msg))
  end

  pcall(vim.loop.fs_write, file, table.concat(lines, "\n") .. "\n", -1)
  pcall(vim.loop.fs_close, file)
  buffer = {}
end

function M.get_logger(ns)
  return setmetatable({}, {
    __index = function(_, level)
      return function(msg, opts)
        log(string.upper(tostring(level)), ns, msg, opts)
      end
    end
  })
end

-- Métodos de conveniência
function M.debug(ns, msg, opts) log("DEBUG", ns, msg, opts) end
function M.info(ns, msg, opts) log("INFO", ns, msg, opts) end
function M.warn(ns, msg, opts) log("WARN", ns, msg, opts) end
function M.error(ns, msg, opts) log("ERROR", ns, msg, opts) end
function M.trace(ns, msg, opts) log("TRACE", ns, msg, opts) end

function M.fatal(ns, msg, opts)
  log("FATAL", ns, msg, opts)
  M.flush()
  error(tostring(msg))
end

-- Status e configuração
function M.is_enabled() return config.enabled end
function M.enable() config.enabled = true end
function M.disable() config.enabled = false end
function M.get_config() return vim.deepcopy(config) end

-- Inicialização automática
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    pcall(M.flush)
  end,
  desc = "Flush debug logs on exit"
})

return M
