-- nvim/lua/utils/init.lua

local fallback_logger = {
  info = function(msg) vim.notify("[UTILS INFO] " .. msg, vim.log.levels.INFO) end,
  error = function(msg) vim.notify("[UTILS ERROR] " .. msg, vim.log.levels.ERROR) end,
}

local debug = require("core.debug.logger") or fallback_logger
debug.info("[utils] Package initializing...")

local function load_module(module_name, fallback)
  local ok, result = pcall(require, module_name)
  if ok then
    debug.info(string.format("[utils] Loaded '%s'.", module_name))
    return result
  else
    debug.error(string.format("[utils] Failed to load '%s': %s", module_name, tostring(result)))
    return fallback or {}
  end
end

local utils = {}

-- Auto-load all lua files in utils/
local scan = vim.loop.fs_scandir(vim.fn.stdpath("config") .. "/lua/utils")
if scan then
  while true do
    local name = vim.loop.fs_scandir_next(scan)
    if not name then break end
    if name:match("%.lua$") and name ~= "init.lua" then
      local mod_name = name:gsub("%.lua$", "")
      utils[mod_name] = load_module("utils." .. mod_name)
    end
  end
end

debug.info("[utils] Package ready.")
return utils

