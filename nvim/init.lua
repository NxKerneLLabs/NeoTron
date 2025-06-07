-- ~/.config/nvim/init.lua
-- Fixed initialization order

-- 1. Load initialization utilities
local init_utils = require("core.init_utils")

-- 2. Bootstrap lazy.nvim
local lazypath = init_utils.bootstrap_lazy()

-- 3. Setup basic options
init_utils.setup_basic_options()

-- 4. Setup lazy.nvim
local lazy_ok, lazy = init_utils.safe_require("lazy")
if not lazy_ok then
  init_utils.emergency_log("CRITICAL: lazy.nvim failed to load!", "ERROR")
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
        local ts_ok, ts_config = init_utils.safe_require("nvim-treesitter.configs")
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
          init_utils.emergency_log("Treesitter configured successfully")
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

init_utils.emergency_log("Lazy.nvim setup completed")

-- 5. Load core modules
local core_ok, core = init_utils.safe_require("core")
if not core_ok then
  init_utils.emergency_log("Failed to load core module!", "ERROR")
  return
end

-- Initialize core modules
if not core.setup() then
  init_utils.emergency_log("Core initialization failed!", "ERROR")
  return
end

-- 6. Load debug system and appearance (after everything else works)
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Try to load debug system after everything else is stable
    local debug_ok = init_utils.safe_require("core.debug")
    if debug_ok then
      init_utils.emergency_log("Debug system loaded (deferred)")
    else
      init_utils.emergency_log("Debug system failed - continuing without it", "WARN")
    end
    
    -- Load appearance/themes
    local appearance_ok = init_utils.safe_require("core.appearance")
    if appearance_ok then
      init_utils.emergency_log("Appearance settings loaded")
    end
  end,
})

-- 7. Install treesitter parsers on first run
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      -- Check if lua parser exists
      local parser_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser/lua.so"
      if not vim.loop.fs_stat(parser_path) then
        init_utils.emergency_log("Installing Lua treesitter parser...")
        vim.cmd("TSInstall lua")
      end
    end)
  end,
})

init_utils.emergency_log("Neovim initialization completed")
