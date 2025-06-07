-- ~/.config/nvim/lua/core/init_utils.lua
local M = {}

-- Global start time for metrics
M.start_time = vim.loop.hrtime()

-- Emergency logging (works without any modules)
function M.emergency_log(msg, level)
  vim.schedule(function()
    local hl = level == "ERROR" and "ErrorMsg" or "WarningMsg"
    vim.api.nvim_echo({{"[INIT] " .. msg, hl}}, true, {})
    io.write("[NVIM_INIT] " .. os.date("%H:%M:%S") .. " " .. msg .. "\n")
  end)
end

-- Safe module loading with better error handling
function M.safe_require(module_name)
  local ok, result = pcall(require, module_name)
  if not ok then
    M.emergency_log("Failed to load " .. module_name .. ": " .. tostring(result), "ERROR")
    return nil, result
  end
  return result, nil
end

-- Bootstrap lazy.nvim
function M.bootstrap_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
  return lazypath
end

-- Setup basic vim options
function M.setup_basic_options()
  -- Set leaders
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  -- Disable problematic providers
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_ruby_provider = 0
end

-- Calculate startup time
function M.get_startup_time()
  return (vim.loop.hrtime() - M.start_time) / 1e6
end

-- Health check function
function M.health_check(modules)
  local issues = {}
  
  -- Check if core modules are loaded
  for _, module in ipairs(modules) do
    if not package.loaded[module] then
      table.insert(issues, "Module not loaded: " .. module)
    end
  end
  
  -- Check leader keys
  if not vim.g.mapleader then
    table.insert(issues, "mapleader not defined")
  end
  
  if not vim.g.maplocalleader then
    table.insert(issues, "maplocalleader not defined")
  end
  
  return #issues == 0, issues
end

return M 