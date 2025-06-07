-- lua/core/debug/safe_require.lua
-- Safe require with cache and fallback notifications

local _mod_cache = {}
local fallback = require("core.debug.fallback")

---@param path string
---@return boolean, table|any
local function safe_require(path)
  if _mod_cache[path] then
    return _mod_cache[path].ok, _mod_cache[path].mod
  end
  local ok, mod = pcall(require, path)
  if not ok then
    fallback.error("Failed to load module '"..path.."': "..tostring(mod))
  elseif type(mod) ~= "table" then
    fallback.warn("Module '"..path.."' returned "..type(mod)..", expected table")
  end
  _mod_cache[path] = { ok = ok, mod = mod }
  return ok, mod
end

return safe_require

