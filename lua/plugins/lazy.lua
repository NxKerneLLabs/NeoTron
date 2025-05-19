-- lua/plugins/lazy.lua
-- Main configuration file for lazy.nvim plugin manager.
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



local start_time = vim.loop.hrtime()
lazy_module.setup(specs_to_load, lazy_opts)
local duration_ms = (vim.loop.hrtime() - start_time) / 1e6


