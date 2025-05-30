-- ~/.config/nvim/init.lua
-- Fixed initialization order

-- 1. BOOTSTRAP LAZY.NVIM FIRST (before anything else)
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

-- 2. SET LEADERS IMMEDIATELY
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 3. DISABLE PROBLEMATIC PROVIDERS (prevents health warnings)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- 4. EMERGENCY LOGGING (works without any modules)
local function emergency_log(msg, level)
  vim.schedule(function()
    local hl = level == "ERROR" and "ErrorMsg" or "WarningMsg"
    vim.api.nvim_echo({{"[INIT] " .. msg, hl}}, true, {})
  end)
end

-- 5. SAFE REQUIRE WITH BETTER ERROR HANDLING
local function safe_require(module_name)
  local ok, result = pcall(require, module_name)
  if not ok then
    emergency_log("Failed to load " .. module_name .. ": " .. tostring(result), "ERROR")
    return nil, result
  end
  return result, nil
end

-- 6. SETUP LAZY.NVIM IMMEDIATELY (before core modules)
local lazy_ok, lazy = safe_require("lazy")
if not lazy_ok then
  emergency_log("CRITICAL: lazy.nvim failed to load!", "ERROR")
  return
end

-- Configure lazy with essential plugins first
lazy.setup({
  spec = {
    -- Essential: Treesitter MUST be first
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      priority = 1000, -- Load first
      config = function()
        local ts_ok, ts_config = safe_require("nvim-treesitter.configs")
        if ts_ok then
          ts_config.setup({
            ensure_installed = { "lua", "vim", "vimdoc", "query" },
            auto_install = true,
            sync_install = false,
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
          })
          emergency_log("Treesitter configured successfully")
        end
      end,
    },
    
    -- Import your other plugins (but they'll load after treesitter)
    { import = "plugins" },
  },
  
  defaults = { 
    lazy = true,
    version = false, -- Don't version lock plugins
  },
  
  install = { 
    colorscheme = { "default" } 
  },
  
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin"
      }
    }
  },
  
  -- Reduce startup noise
  checker = { enabled = false },
  change_detection = { enabled = false },
})

emergency_log("Lazy.nvim setup completed")

-- 7. LOAD CORE MODULES (after lazy is working)
-- Load basic options first (no dependencies)
local options_ok = safe_require("core.options")
if options_ok then
  emergency_log("Core options loaded")
end

-- Load autocmds (minimal dependencies)
local autocmds_ok = safe_require("core.autocmds")
if autocmds_ok then
  emergency_log("Core autocmds loaded")
end

-- Load keymaps (may depend on plugins being available)
local keymaps_ok = safe_require("core.keymaps")
if keymaps_ok then
  emergency_log("Core keymaps loaded")
end

-- 8. LOAD DEBUG SYSTEM LAST (after everything else works)
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Try to load debug system after everything else is stable
    local debug_ok = safe_require("core.debug")
    if debug_ok then
      emergency_log("Debug system loaded (deferred)")
    else
      emergency_log("Debug system failed - continuing without it", "WARN")
    end
    
    -- Load appearance/themes
    local appearance_ok = safe_require("core.appearance")
    if appearance_ok then
      emergency_log("Appearance settings loaded")
    end
  end,
})

-- 9. INSTALL TREESITTER PARSERS ON FIRST RUN
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      -- Check if lua parser exists
      local parser_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser/lua.so"
      if not vim.loop.fs_stat(parser_path) then
        emergency_log("Installing Lua treesitter parser...")
        vim.cmd("TSInstall lua")
      end
    end)
  end,
})

emergency_log("Neovim initialization completed")
