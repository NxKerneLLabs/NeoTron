-- nvim/lua/core/debug/profiler.lua
-- Tools for profiling performance

local logger = require("core.debug.logger")

local M = {}

function M.profile(func, namespace, name)
  local func_name = name or "anonymous_function"
  return function(...)
    local start_time = vim.loop.hrtime()
    local results = table.pack(func(...))
    local duration_ms = (vim.loop.hrtime() - start_time) / 1e6
    logger.info(namespace, string.format("Function '%s' executed in %.2fms", func_name, duration_ms))
    return table.unpack(results, 1, results.n)
  end
end
