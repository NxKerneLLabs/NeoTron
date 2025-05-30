-- nvim/lua/core/debug/config.lua
-- Configuration for the debug system

local M = {}

--tls_cert = "/caminho/para/server.crt",
--tls_key  = "/caminho/para/server.key",

-- Default log file and levels
M.log_file         = vim.fn.stdpath("data") .. "/nvim-debug.log"
M.log_level        = vim.log.levels.DEBUG
M.max_file_size    = 1024 * 1024    -- 1 MB
M.enabled          = true
M.buffer_size      = 100
M.flush_interval   = 5000           -- in milliseconds
M.stacktrace_depth = 10             -- max stacktrace lines for error logs

-- Advanced features
M.silent_mode      = false          -- when true, suppresses vim.notify for INFO+ logs
M.compress_backups = true           -- gzip .bak files if available
M.performance_log  = false           -- log internal performance metrics

-- Namespace-specific log levels
M.namespaces = {
  ["global"]    = vim.log.levels.INFO,
  ["which-key"] = vim.log.levels.DEBUG,
  ["lsp"]       = vim.log.levels.INFO,
  ["telescope"] = vim.log.levels.WARN,
  ["default"]   = vim.log.levels.DEBUG,
}

--- Update configuration at runtime
-- @param new_cfg table of keys to update
-- @return updated config table
function M.update(new_cfg)
  if type(new_cfg) ~= "table" then
    vim.notify("[debug.config] update() requires a table", vim.log.levels.WARN)
    return M
  end
  for k, v in pairs(new_cfg) do
    if M[k] == nil then
      vim.notify("[debug.config] Unknown config key: " .. tostring(k), vim.log.levels.WARN)
    else
      -- Optional type checks
      if k == "buffer_size" or k == "max_file_size" or k == "flush_interval" then
        if type(v) ~= "number" then
          vim.notify("[debug.config] Expected number for "..k..", got "..type(v), vim.log.levels.WARN)
        else
          M[k] = v
        end
      elseif k == "enabled" or k == "silent_mode" or k == "compress_backups" or k == "performance_log" then
        if type(v) ~= "boolean" then
          vim.notify("[debug.config] Expected boolean for "..k..", got "..type(v), vim.log.levels.WARN)
        else
          M[k] = v
        end
      elseif k == "log_level" then
        if type(v) ~= "number" then
          vim.notify("[debug.config] Expected numeric log_level, got "..type(v), vim.log.levels.WARN)
        else
          M[k] = v
        end
      elseif k == "stacktrace_depth" then
        if type(v) ~= "number" then
          vim.notify("[debug.config] Expected number for stacktrace_depth, got "..type(v), vim.log.levels.WARN)
        else
          M[k] = v
        end
      elseif k == "namespaces" then
        if type(v) ~= "table" then
          vim.notify("[debug.config] Expected table for namespaces, got "..type(v), vim.log.levels.WARN)
        else
          M.namespaces = v
        end
      else
        M[k] = v
      end
    end
  end
  return M
end

return M

