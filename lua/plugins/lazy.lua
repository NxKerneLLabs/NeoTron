-- lua/plugins/lazy.lua
-- Main configuration file for lazy.nvim plugin manager.

-- Obtain a namespaced logger from core.debug
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.lazy")) or fallback
  -- Fallback basic logging if core.debug or get_logger is not available.
  logger = {
    info = function(msg) vim.notify("LAZY_SETUP INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("LAZY_SETUP ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("LAZY_SETUP WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("LAZY_SETUP DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  elseif not core_debug.get_logger then
     logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end


-- Function to bootstrap lazy.nvim if it's not already installed.
local function bootstrap_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    logger.info("Installing lazy.nvim...")
    -- Ensure the parent directory exists
    vim.fn.mkdir(vim.fn.stdpath("data") .. "/lazy", "p")
    local clone_status, clone_err = vim.fn.system({
      "git", "clone", "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", lazypath,
    })
    if clone_status ~= 0 then
        logger.error("Failed to clone lazy.nvim. Git command exited with status " .. clone_status .. ". Error: " .. tostring(clone_err))
        vim.notify("FATAL: Failed to install lazy.nvim. Check logs and ensure Git is installed.", vim.log.levels.ERROR)
        return false -- Indicate failure
    end
    logger.info("lazy.nvim installed successfully at: " .. lazypath)
  else
    logger.info("lazy.nvim already installed at: " .. lazypath)
  end
  vim.opt.rtp:prepend(lazypath) -- Add lazy.nvim to the runtime path.
  return true -- Indicate success
end

if not bootstrap_lazy() then
    logger.error("Halting plugin setup due to lazy.nvim bootstrap failure.")
    return {} -- Return empty specs if bootstrap fails
end

-- Default options for lazy.nvim.
local lazy_opts = {
  defaults = {
    lazy = true, -- Load plugins on demand by default.
    version = false, -- false = latest commit; string = branch/tag (e.g., "*", "v2.*")
  },
  install = {
    -- Default colorscheme to use if a theme is not set elsewhere or during initial install.
    colorscheme = { vim.g.selected_theme_name or "tokyonight", "tokyonight", "habamax" },
    missing = true, -- install missing plugins on startup
  },
  performance = {
    rtp = {
      -- Disable unused built-in Vim plugins to improve startup time.
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded", -- Use rounded borders for the lazy.nvim UI.
    -- Custom icons for UI elements (optional)
    -- icons = { cmd = " ", config = " ", dap = " ", event = " ", ft = " ", init = " ",
    --           keys = " ", lazy = "󰒲 ", loaded = "●", loading = "○", lock = " ",
    --           not_loaded = "○", optional = " ", plugin = " ", runtime = " ",
    --           source = " ", start = " ", task = "✔ ", require = "󰢱 " },
  },
  change_detection = {
    enabled = true, -- Automatically check for config changes.
    notify = true,  -- Notify when changes are detected.
  },
  checker = {
    enabled = true,    -- Check for plugin updates automatically.
    frequency = 3600,  -- Check every hour (in seconds).
    notify = true,     -- Notify about updates
  },
  rocks = {
    enabled = false, -- Disable Luarocks support if not using plugins that require it.
  },
  dev = {
    -- paths = { "~/projects/my-neovim-plugin" }, -- For local plugin development
    fallback = true, -- Fallback to git when local plugin is not found
  },
  -- Configure logging for lazy.nvim itself
  -- logger = logger, -- You could pass your custom logger, but lazy has its own good one.
  -- For lazy's own debug logs, set `debug = true` (as you have)
  debug = true, -- Set to true for verbose lazy.nvim output, false for normal use.
}

-- List of modules in 'lua/plugins/' that return plugin specifications.
-- Ensure these paths are correct relative to your 'lua' directory.
local plugin_spec_files = {
  "plugins.ui",
  "plugins.which-key",
  "plugins.lsp",
  "plugins.cmp",
  "plugins.neo-tree",
  "plugins.treesitter",
  "plugins.git",
  "plugins.telescope",
  "plugins.nvimtree",
  "plugins.terminal",
  "plugins.dap",
  "which-key-lsp"
}

local specs_to_load = {} -- Table to hold all collected plugin specifications.

logger.info("Collecting plugin specifications...")
for _, spec_file_module_name in ipairs(plugin_spec_files) do
  local import_ok, imported_content = pcall(require, spec_file_module_name)
  if import_ok then
    if type(imported_content) == "table" then
      -- Check if it's a list of specs or a single spec
      if #imported_content > 0 and type(imported_content[1]) == "table" then -- Likely a list
        for i, single_spec in ipairs(imported_content) do
          if type(single_spec) == "table" then
            table.insert(specs_to_load, single_spec)
          else
            logger.warn("Item #" .. i .. " in '" .. spec_file_module_name .. "' is not a table (plugin spec). Ignoring.")
          end
        end
        logger.debug("Plugin specifications from '" .. spec_file_module_name .. "' (list) processed: " .. #imported_content .. " specs added.")
      elseif (imported_content[1] ~= nil and type(imported_content[1]) == "string") or imported_content.name or type(imported_content) == "string" then
        -- Looks like a single plugin spec (string or table with plugin name)
        table.insert(specs_to_load, imported_content)
        logger.debug("Plugin specification from '" .. spec_file_module_name .. "' (single) processed.")
      else
        logger.warn("Content of '" .. spec_file_module_name .. "' is a table, but not a recognized plugin spec format. Ignoring.")
      end
    else
      logger.warn("Module '" .. spec_file_module_name .. "' did not return a table. Returned: " .. tostring(imported_content) .. ". Ignoring.")
    end
  else
    logger.error("Failed to load plugin specification file: '" .. spec_file_module_name .. "'. Error: " .. tostring(imported_content))
  end
end

logger.info("Total plugin specifications collected for lazy.setup: " .. #specs_to_load)

-- Safely require and setup lazy.nvim
local lazy_setup_ok, lazy_module = pcall(require, "lazy")
if not lazy_setup_ok then
  logger.error("CRITICAL FAILURE loading lazy.nvim module. Plugin setup aborted. Error: " .. tostring(lazy_module))
  vim.notify("CRITICAL ERROR: lazy.nvim could not be loaded. Check logs.", vim.log.levels.ERROR)
  return {} -- Return empty specs to avoid further errors
end

local start_time = vim.loop.hrtime()
lazy_module.setup(specs_to_load, lazy_opts)
local duration_ms = (vim.loop.hrtime() - start_time) / 1e6

-- Use Neovim's scheduler to ensure the message appears after startup messages
vim.schedule(function()
    logger.info("lazy.nvim initialized in " .. string.format("%.2f", duration_ms) .. "ms with " .. #specs_to_load .. " plugin specifications processed.")
end)

-- No need to return anything from this file as lazy.setup() handles everything.

