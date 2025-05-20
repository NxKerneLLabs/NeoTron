-- lua/core/debug/fallback.lua
local fallback = {}
local levels = { "DEBUG", "INFO", "WARN", "ERROR" }
for _, lvl in ipairs(levels) do
  local num = vim.log.levels[lvl] or vim.log.levels.INFO
  fallback[lvl:lower()] = function(msg)
    vim.notify(string.format("FALLBACK [%s] %s", lvl, msg), num)
  end
end
return fallback
