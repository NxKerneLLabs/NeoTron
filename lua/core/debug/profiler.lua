local function safe_require(path)
  if _mod_cache[path] then
    return _mod_cache[path].ok, _mod_cache[path].mod
  end
  local ok, mod = pcall(require, path)
  if not ok then
    initial_notify("Failed to load " .. path .. ": " .. tostring(mod), vim.log.levels.ERROR)
  elseif type(mod) ~= "table" then
    initial_notify("Module " .. path .. " returned " .. type(mod) .. ", expected table", vim.log.levels.ERROR)
  end
  _mod_cache[path] = { ok = ok, mod = mod }
  return ok, mod
end
