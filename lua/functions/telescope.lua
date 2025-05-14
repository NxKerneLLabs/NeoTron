-- nvim/lua/functions/telescope.lua
-- Custom utility functions for Telescope plugin

local M = {}

-- Obtain a namespaced logger from core.debug
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("functions.telescope")
else
  logger = { -- Fallback basic logging
    info = function(msg) vim.notify("TELESCOPE_FN INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("TELESCOPE_FN ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("TELESCOPE_FN WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("TELESCOPE_FN DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  else
    logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

-- Safely require Telescope modules
local builtin_ok, builtin = pcall(require, "telescope.builtin")
local themes_ok, themes = pcall(require, "telescope.themes")
-- actions and action_layout are not directly used by the functions M exposes,
-- but good to be aware of if you expand this module.

if not builtin_ok then
  logger.error("Failed to load 'telescope.builtin'. Telescope functions will be non-operational. Error: " .. tostring(builtin))
end
if not themes_ok then
  logger.warn("Failed to load 'telescope.themes'. Themed Telescope functions might not work as expected. Error: " .. tostring(themes))
end

-- Helper function to call telescope builtins safely
local function safe_telescope_call(picker_name, opts, default_title)
  if not builtin_ok or not builtin[picker_name] then
    logger.error("'telescope.builtin." .. picker_name .. "' not available.")
    return
  end
  opts = opts or {}
  opts.prompt_title = opts.prompt_title or default_title or ("󰍉 " .. picker_name) -- Using a generic fuzzy icon

  logger.debug("Telescope: Executing " .. picker_name .. " with options: " .. vim.inspect(opts))
  local success, err = pcall(builtin[picker_name], opts)
  if not success then
    logger.error("Error executing Telescope picker '" .. picker_name .. "': " .. tostring(err))
  end
end

--- Finds files in the current working directory (or project root).
function M.find_files(opts)
  safe_telescope_call("find_files", vim.tbl_deep_extend("force", {
    hidden = true,
    no_ignore = false, -- Respects .gitignore
    -- Example: find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
  }, opts or {}), "🔍 Find Files")
end

--- Performs a live grep for a string in files.
function M.live_grep(opts)
  safe_telescope_call("live_grep", vim.tbl_deep_extend("force", {
    -- Example: vimgrep_arguments to customize rg behavior
  }, opts or {}), "🔎 Live Grep")
end

--- Lists currently open buffers.
function M.buffers(opts)
  safe_telescope_call("buffers", vim.tbl_deep_extend("force", {
    sort_mru = true,
    ignore_current_buffer = true,
  }, opts or {}), "📄 Open Buffers")
end

--- Searches Vim help tags.
function M.help_tags(opts)
  safe_telescope_call("help_tags", opts, "📚 Help Tags")
end

--- Shows recently opened files (oldfiles).
function M.recent_files(opts) -- Renamed from oldfiles for clarity
  safe_telescope_call("oldfiles", opts, "🕘 Recent Files")
end

--- Lists available Vim commands.
function M.commands(opts)
  safe_telescope_call("commands", opts, " Commands")
end

--- Shows LSP document symbols for the current buffer.
function M.document_symbols(opts)
  safe_telescope_call("lsp_document_symbols", opts, "󰘧 Document Symbols")
end

--- Shows LSP workspace symbols.
function M.workspace_symbols(opts)
  safe_telescope_call("lsp_workspace_symbols", opts, "󰌗 Workspace Symbols")
end

--- Searches for files within the Neovim configuration directory.
function M.config_files(opts) -- Renamed from config_search
  local config_path = vim.fn.stdpath("config")
  if not (vim.fn.isdirectory(config_path) == 1) then
    return logger.warn("Neovim config directory not found at: " .. config_path)
  end
  local default_opts = { cwd = config_path }
  if themes_ok and themes.get_dropdown then -- Apply theme if available
    default_opts = themes.get_dropdown(default_opts)
  end
  safe_telescope_call("find_files", vim.tbl_deep_extend("force", default_opts, opts or {}), " Config Files")
end

--- Searches for files within a specified dotfiles directory.
function M.dotfiles(opts) -- Renamed from search_dotfiles
  local dotfiles_path = vim.env.HOME .. "/.dotfiles" -- Make this configurable if needed
  if not (vim.fn.isdirectory(dotfiles_path) == 1) then
    return logger.warn("Dotfiles directory not found at: " .. dotfiles_path)
  end
  safe_telescope_call("find_files", vim.tbl_deep_extend("force", {
    cwd = dotfiles_path,
    hidden = true,
  }, opts or {}), "󰒓 Dotfiles")
end

--- Searches keymaps.
function M.keymaps(opts)
  safe_telescope_call("keymaps", opts, "󰌌 Keymaps")
end

--- Searches marks.
function M.marks(opts)
  safe_telescope_call("marks", opts, "󰃀 Marks")
end

--- Searches Treesitter symbols for the current buffer.
function M.treesitter(opts) -- Renamed from treesitter_symbols to match Telescope's own picker name
  safe_telescope_call("treesitter", opts, " Treesitter Symbols")
end

--- Searches for projects (requires an extension like telescope-project.nvim).
function M.projects(opts)
  if not (builtin_ok and builtin.extensions and builtin.extensions.project and builtin.extensions.project.project) then
    logger.warn("Telescope 'project' extension not found or 'project' picker unavailable. Cannot execute projects picker.")
    vim.notify("Telescope 'project' extension not loaded.", vim.log.levels.WARN)
    return
  end
  logger.debug("Telescope: Executing projects (via extension).")
  safe_telescope_call("extensions.project.project", opts, " Projects")
end

--- Fuzzy find in the current buffer.
function M.current_buffer_fuzzy_find(opts)
  safe_telescope_call("current_buffer_fuzzy_find", opts, "󰍉 Search in Buffer")
end

-- Add get_project_root if it's used by other modules and not part of telescope_fns itself
function M.get_project_root()
    -- This function's logic depends on how you determine project root.
    -- Example using project.nvim if available:
    local project_nvim_ok, project_module = pcall(require, "project_nvim.project")
    if project_nvim_ok and project_module and project_module.get_project_root then
        local root = project_module.get_project_root()
        if root then
            logger.debug("Project root (project.nvim): " .. root)
            return root
        end
    end
    -- Fallback to LSP root dir or current working directory
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #clients > 0 and clients[1].root_dir then
        logger.debug("Project root (LSP): " .. clients[1].root_dir)
        return clients[1].root_dir
    end
    local cwd = vim.fn.getcwd()
    logger.debug("Project root (fallback CWD): " .. cwd)
    return cwd
end


logger.info("Telescope utility functions (lua/functions/telescope.lua) loaded.")
return M

