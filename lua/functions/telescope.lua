-- nvim/lua/functions/telescope.lua
-- Advanced utility functions for Telescope plugin

local M = {}

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                     Configuration                         │
  ╰──────────────────────────────────────────────────────────╯
]]

-- User configurable options with reasonable defaults
local config = {
  icons = {
    files = "🔍",
    grep = "🔎",
    buffers = "📄",
    help = "📚",
    recent = "🕘",
    commands = "",
    doc_symbols = "󰘧",
    workspace_symbols = "󰌗",
    config = "",
    dotfiles = "󰒓",
    keymaps = "󰌌",
    marks = "󰃀",
    treesitter = "",
    projects = "",
    buffer_find = "󰍉",
  },
  
  -- Paths for various operations
  paths = {
    config = vim.fn.stdpath("config"),
    dotfiles = vim.env.HOME .. "/.dotfiles",
  },
  
  -- Default options for telescope pickers
  default_options = {
    find_files = {
      hidden = true,
      no_ignore = false,
    },
    live_grep = {},
    buffers = {
      sort_mru = true,
      ignore_current_buffer = true,
    },
  },
  
  -- Project root detection methods in order of preference
  root_patterns = {
    ".git",
    ".svn",
    ".hg",
    "package.json",
    "Cargo.toml",
    "pyproject.toml",
  },
  
  -- Debug settings
  debug = {
    enabled = false,
    level = "info", -- debug, info, warn, error
  },
}

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                         Logger                            │
  ╰──────────────────────────────────────────────────────────╯
]]

-- Enhanced logger implementation with better fallback
local logger = (function()
  local logger_instance
  local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
  
  if core_debug_ok and core_debug and core_debug.get_logger then
    logger_instance = core_debug.get_logger("functions.telescope")
  else
    -- Create a more sophisticated fallback logger
    local log_levels = {
      DEBUG = 1,
      INFO = 2,
      WARN = 3,
      ERROR = 4,
    }
    
    local current_level = log_levels[string.upper(config.debug.level)] or log_levels.INFO
    
    logger_instance = {
      debug = function(msg)
        if current_level <= log_levels.DEBUG then
          vim.notify("TELESCOPE_FN DEBUG: " .. msg, vim.log.levels.DEBUG)
        end
      end,
      info = function(msg)
        if current_level <= log_levels.INFO then
          vim.notify("TELESCOPE_FN INFO: " .. msg, vim.log.levels.INFO)
        end
      end,
      warn = function(msg)
        if current_level <= log_levels.WARN then
          vim.notify("TELESCOPE_FN WARN: " .. msg, vim.log.levels.WARN)
        end
      end,
      error = function(msg)
        if current_level <= log_levels.ERROR then
          vim.notify("TELESCOPE_FN ERROR: " .. msg, vim.log.levels.ERROR)
        end
      end,
      set_level = function(level)
        current_level = log_levels[string.upper(level)] or current_level
      end
    }
    
    -- Log the reason for fallback
    if not core_debug_ok then
      logger_instance.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
    else
      logger_instance.error("core.debug.get_logger function not found. Using fallback logger.")
    end
  end
  
  return logger_instance
end)()

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                      Dependencies                         │
  ╰──────────────────────────────────────────────────────────╯
]]

-- Lazy-loaded telescope dependencies
local dependencies = {
  _cache = {},
  
  -- Get a module, with caching to avoid repeated pcalls
  get = function(self, module_name)
    if self._cache[module_name] == nil then
      local ok, module = pcall(require, module_name)
      if ok then
        self._cache[module_name] = module
      else
        self._cache[module_name] = false
        logger.error("Failed to load '" .. module_name .. "'. Error: " .. tostring(module))
      end
    end
    return self._cache[module_name]
  end,
  
  -- Check if a module is available
  has = function(self, module_name)
    return self:get(module_name) ~= false
  end,
  
  -- Get a function from a module, safely
  get_fn = function(self, module_name, fn_name)
    local module = self:get(module_name)
    if not module then return nil end
    
    if type(fn_name) == "string" then
      if module[fn_name] then
        return module[fn_name]
      end
      logger.debug("Function '" .. fn_name .. "' not found in module '" .. module_name .. "'")
      return nil
    end
    
    return module
  end
}

-- Helper to get themes with fallback
local function get_theme(theme_name, opts)
  local themes = dependencies:get("telescope.themes")
  if not themes or not themes[theme_name] then return opts end
  
  return themes[theme_name](opts)
end

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                    Helper Functions                       │
  ╰──────────────────────────────────────────────────────────╯
]]

-- Debounce function to prevent rapid consecutive calls
local function debounce(fn, ms)
  local timer = vim.loop.new_timer()
  return function(...)
    local args = {...}
    timer:stop()
    timer:start(ms, 0, function()
      vim.schedule(function()
        fn(unpack(args))
      end)
    end)
  end
end

-- Enhanced helper function to call telescope builtins safely
local function safe_telescope_call(picker_name, opts, default_title)
  local builtin = dependencies:get("telescope.builtin")
  local picker_fn = dependencies:get_fn("telescope.builtin", picker_name)
  
  if not picker_fn then
    logger.error("Telescope picker '" .. picker_name .. "' not available.")
    vim.notify("Telescope picker '" .. picker_name .. "' not available.", vim.log.levels.ERROR)
    return false
  end
  
  opts = opts or {}
  opts.prompt_title = opts.prompt_title or default_title or (config.icons[picker_name:gsub("_", "")] or "󰍉") .. " " .. picker_name:gsub("_", " "):gsub("^%l", string.upper)

  logger.debug("Telescope: Executing " .. picker_name .. " with options: " .. vim.inspect(opts))
  
  local success, err = pcall(picker_fn, opts)
  if not success then
    logger.error("Error executing Telescope picker '" .. picker_name .. "': " .. tostring(err))
    vim.notify("Error in Telescope picker: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Enhanced project root detection
function M.get_project_root()
  -- Cache the result to avoid repeated lookups
  if M._project_root_cache then
    return M._project_root_cache
  end
  
  -- Try project.nvim first if available
  local project_nvim = dependencies:get("project_nvim.project")
  if project_nvim and project_nvim.get_project_root then
    local root = project_nvim.get_project_root()
    if root then
      logger.debug("Project root (project.nvim): " .. root)
      M._project_root_cache = root
      return root
    end
  end
  
  -- Try LSP root directory
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients > 0 and clients[1].config and clients[1].config.root_dir then
    logger.debug("Project root (LSP): " .. clients[1].config.root_dir)
    M._project_root_cache = clients[1].config.root_dir
    return clients[1].config.root_dir
  end
  
  -- Try to find root by common patterns
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  
  for _, pattern in ipairs(config.root_patterns) do
    local parent_dir = current_dir
    while parent_dir ~= "/" do
      local check_path = parent_dir .. "/" .. pattern
      if vim.fn.filereadable(check_path) == 1 or vim.fn.isdirectory(check_path) == 1 then
        logger.debug("Project root (pattern " .. pattern .. "): " .. parent_dir)
        M._project_root_cache = parent_dir
        return parent_dir
      end
      parent_dir = vim.fn.fnamemodify(parent_dir, ":h")
    end
  end
  
  -- Fallback to CWD
  local cwd = vim.fn.getcwd()
  logger.debug("Project root (fallback CWD): " .. cwd)
  M._project_root_cache = cwd
  return cwd
end

-- Clear the project root cache when the directory changes
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    M._project_root_cache = nil
  end
})

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                  Configuration Functions                  │
  ╰──────────────────────────────────────────────────────────╯
]]

-- Update configuration with user options
function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", config, opts)
  
  -- Update logger level if specified
  if config.debug and config.debug.level then
    logger.set_level(config.debug.level)
  end
  
  logger.info("Telescope functions configured with options: " .. vim.inspect(config))
  return M
end

-- Reset cached state (useful for testing)
function M.reset_cache()
  M._project_root_cache = nil
  dependencies._cache = {}
  logger.debug("Telescope functions cache reset")
end

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                 File Navigation Functions                 │
  ╰──────────────────────────────────────────────────────────╯
]]

--- Finds files in the current working directory (or project root).
--- @param opts table|nil Optional configuration table
function M.find_files(opts)
  opts = vim.tbl_deep_extend("force", config.default_options.find_files, opts or {})
  return safe_telescope_call("find_files", opts, config.icons.files .. " Find Files")
end

--- Shows recently opened files (oldfiles).
--- @param opts table|nil Optional configuration table
function M.recent_files(opts) 
  return safe_telescope_call("oldfiles", opts, config.icons.recent .. " Recent Files")
end

--- Searches for files within the Neovim configuration directory.
--- @param opts table|nil Optional configuration table
function M.config_files(opts)
  local config_path = config.paths.config
  if not (vim.fn.isdirectory(config_path) == 1) then
    vim.notify("Neovim config directory not found at: " .. config_path, vim.log.levels.WARN)
    return false
  end
  
  local default_opts = { cwd = config_path }
  default_opts = get_theme("get_dropdown", default_opts)
  
  return safe_telescope_call("find_files", vim.tbl_deep_extend("force", default_opts, opts or {}), 
    config.icons.config .. " Config Files")
end

--- Searches for files within a specified dotfiles directory.
--- @param opts table|nil Optional configuration table
function M.dotfiles(opts) 
  local dotfiles_path = config.paths.dotfiles
  if not (vim.fn.isdirectory(dotfiles_path) == 1) then
    vim.notify("Dotfiles directory not found at: " .. dotfiles_path, vim.log.levels.WARN)
    return false
  end
  
  return safe_telescope_call("find_files", vim.tbl_deep_extend("force", {
    cwd = dotfiles_path,
    hidden = true,
  }, opts or {}), config.icons.dotfiles .. " Dotfiles")
end

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                 Search & Grep Functions                   │
  ╰──────────────────────────────────────────────────────────╯
]]

--- Performs a live grep for a string in files.
--- @param opts table|nil Optional configuration table
function M.live_grep(opts)
  opts = vim.tbl_deep_extend("force", config.default_options.live_grep, opts or {})
  return safe_telescope_call("live_grep", opts, config.icons.grep .. " Live Grep")
end

--- Project-scoped live grep that respects your project root
--- @param opts table|nil Optional configuration table
function M.project_grep(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or M.get_project_root()
  return M.live_grep(opts)
end

--- Fuzzy find in the current buffer.
--- @param opts table|nil Optional configuration table
function M.current_buffer_fuzzy_find(opts)
  return safe_telescope_call("current_buffer_fuzzy_find", opts, config.icons.buffer_find .. " Search in Buffer")
end

-- Debounced version of buffer search for real-time searching
M.buffer_search_debounced = debounce(function(opts)
  M.current_buffer_fuzzy_find(opts)
end, 300)

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │              Buffer Management Functions                  │
  ╰──────────────────────────────────────────────────────────╯
]]

--- Lists currently open buffers.
--- @param opts table|nil Optional configuration table
function M.buffers(opts)
  opts = vim.tbl_deep_extend("force", config.default_options.buffers, opts or {})
  return safe_telescope_call("buffers", opts, config.icons.buffers .. " Open Buffers")
end

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                 Documentation Functions                   │
  ╰──────────────────────────────────────────────────────────╯
]]

--- Searches Vim help tags.
--- @param opts table|nil Optional configuration table
function M.help_tags(opts)
  return safe_telescope_call("help_tags", opts, config.icons.help .. " Help Tags")
end

--- Man page search
--- @param opts table|nil Optional configuration table
function M.man_pages(opts)
  return safe_telescope_call("man_pages", opts, "📑 Man Pages")
end

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                 Code Navigation Functions                 │
  ╰──────────────────────────────────────────────────────────╯
]]

--- Shows LSP document symbols for the current buffer.
--- @param opts table|nil Optional configuration table
function M.document_symbols(opts)
  return safe_telescope_call("lsp_document_symbols", opts, config.icons.doc_symbols .. " Document Symbols")
end

--- Shows LSP workspace symbols.
--- @param opts table|nil Optional configuration table
function M.workspace_symbols(opts)
  return safe_telescope_call("lsp_workspace_symbols", opts, config.icons.workspace_symbols .. " Workspace Symbols")
end

--- Searches Treesitter symbols for the current buffer.
--- @param opts table|nil Optional configuration table
function M.treesitter(opts)
  return safe_telescope_call("treesitter", opts, config.icons.treesitter .. " Treesitter Symbols")
end

--- Lists available LSP code actions
--- @param opts table|nil Optional configuration table
function M.lsp_code_actions(opts)
  return safe_telescope_call("lsp_code_actions", opts, "⚡ Code Actions")
end

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                   Vim-specific Functions                  │
  ╰──────────────────────────────────────────────────────────╯
]]

--- Lists available Vim commands.
--- @param opts table|nil Optional configuration table
function M.commands(opts)
  return safe_telescope_call("commands", opts, config.icons.commands .. " Commands")
end

--- Searches keymaps.
--- @param opts table|nil Optional configuration table
function M.keymaps(opts)
  return safe_telescope_call("keymaps", opts, config.icons.keymaps .. " Keymaps")
end

--- Searches marks.
--- @param opts table|nil Optional configuration table
function M.marks(opts)
  return safe_telescope_call("marks", opts, config.icons.marks .. " Marks")
end

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                    Project Functions                      │
  ╰──────────────────────────────────────────────────────────╯
]]

--- Searches for projects (requires telescope-project extension).
--- @param opts table|nil Optional configuration table
function M.projects(opts)
  local builtin = dependencies:get("telescope.builtin")
  if not (builtin and builtin.extensions and builtin.extensions.project 
          and builtin.extensions.project.project) then
    vim.notify("Telescope 'project' extension not loaded. Try running ':Telescope extensions project'.", 
               vim.log.levels.WARN)
    return false
  end
  
  logger.debug("Telescope: Executing projects (via extension).")
  return safe_telescope_call("extensions.project.project", opts, config.icons.projects .. " Projects")
end

--[[ 
  ╭──────────────────────────────────────────────────────────╮
  │                 AI-Enhanced Functions                     │
  ╰──────────────────────────────────────────────────────────╯
]]

-- These functions would integrate with AI services, placeholder for now
--- Semantic code search using AI
function M.semantic_search(query, opts)
  opts = opts or {}
  -- This would integrate with an AI service to provide semantic search
  vim.notify("Semantic search not yet implemented. Would search for: " .. query, vim.log.levels.INFO)
  return false
end

--- AI-assisted project navigation based on your editing patterns
function M.smart_navigation(opts)
  opts = opts or {}
  -- This would use AI to suggest files based on your editing patterns
  vim.notify("Smart navigation not yet implemented.", vim.log.levels.INFO)
  return false
end

-- Initialize the module
logger.info("Telescope utility functions (lua/functions/telescope.lua) loaded.")
return M
