-- lua/core/debug/profiler.lua
-- Simple profiling utilities for measuring function execution time and reporting results
local M = {}
local uv = vim.loop
local fmt = string.format

-- Internal store for profiling data
local profiles = {}

--- Start profiling a named section
-- @param name string: unique identifier for the profile session
function M.start(name)
  if not profiles[name] then
    profiles[name] = { start = 0, elapsed = 0 }
  end
  if profiles[name].start ~= 0 then
    error(fmt("Profile '%s' already started", name))
  end
  profiles[name].start = uv.hrtime()
end

--- Stop profiling a named section and record elapsed time
-- @param name string: identifier started with M.start
-- @return elapsed_ms number: time in milliseconds
function M.stop(name)
  local entry = profiles[name]
  if not entry or entry.start == 0 then
    error(fmt("Profile '%s' was not started", name))
  end
  local elapsed = (uv.hrtime() - entry.start) / 1000000 -- Corrigido pra milissegundos
  entry.elapsed = elapsed
  entry.start = 0 -- Reset start time after stopping
  return elapsed
end

--- Report profiling results for one or all sessions
-- @param name string|nil: optional specific profile name
-- @return table: profiling data
function M.report(name)
  local result = {}
  if name then
    if not profiles[name] then error(fmt("No profile named '%s'", name)) end
    result[name] = profiles[name].elapsed
  else
    for k, v in pairs(profiles) do
      result[k] = v.elapsed or 0
    end
  end
  return result
end

--- Clear profiling data
-- @param name string|nil: optional specific profile name
function M.clear(name)
  if name then
    profiles[name] = nil
  else
    profiles = {}
  end
end

--- Initialize default profiles for common Neovim sections
-- @param override boolean|nil: if true, reset existing profiles
function M.init_default_profiles(override)
  if override then
    profiles = {}
  end
  -- Preenche com profiles comuns pro Neovim
  local default_profiles = {
    "startup",          -- Tempo de inicialização do Neovim
    "plugin_load",      -- Tempo de carregamento de plugins
    "keymap_setup",     -- Tempo de configuração de keymaps
    "lsp_init",         -- Tempo de inicialização do LSP
    "buffer_open",      -- Tempo pra abrir um buffer
  }
  for _, name in ipairs(default_profiles) do
    if not profiles[name] or override then
      profiles[name] = { start = 0, elapsed = 0 }
    end
  end
  return default_profiles
end

return M

