-- nvim/lua/keymaps/which-key/telescope.lua
-- Registers Telescope keybindings with which-key.nvim.

local M = {}

function M.register(wk_instance, logger)
  if not logger then
    print("ERROR [keymaps.which-key.telescope]: Logger not provided. Using fallback print.")
    logger = {
      info = function(msg) print("INFO [KWTELE_FB]: " .. msg) end,
      error = function(msg) print("ERROR [KWTELE_FB]: " .. msg) end,
      warn = function(msg) print("WARN [KWTELE_FB]: " .. msg) end,
      debug = function(msg) print("DEBUG [KWTELE_FB]: " .. msg) end,
    }
  end

  if not wk_instance then
    logger.error("which-key instance not provided. Cannot register Telescope keymaps.")
    return false -- Indicate failure
  end

  local telescope_fns_ok, telescope_fns = pcall(require, "functions.telescope")
  if not telescope_fns_ok or not telescope_fns then
    logger.error("Failed to load 'functions.telescope' module. Cannot register Telescope keymaps. Error: " .. tostring(telescope_fns))
    return false
  end

  -- Load icons with fallbacks
  local icons_module_ok, icons_module = pcall(require, "utils.icons")
  local icons
  if not icons_module_ok or not icons_module then
    logger.warn("Using text fallbacks for Telescope which-key names - 'utils.icons' not found. Error: " .. tostring(icons_module))
    icons = {
      ui = { search = "", fuzzy = "󰍉", folder = "", file = "", code = "󰘧" },
      misc = { command = "", project = "", buffer = "󰓩", mark = "󰃀", help = "", keymap = "󰌌", grep = "󱎸", config = "󰒓", tree = "", symbol = "󰯻" },
    }
  else
    icons = icons_module
    icons.ui = icons.ui or { search = "", fuzzy = "󰍉", folder = "", file = "", code = "󰘧" }
    icons.misc = icons.misc or { command = "", project = "", buffer = "󰓩", mark = "󰃀", help = "", keymap = "󰌌", grep = "󱎸", config = "󰒓", tree = "", symbol = "󰯻" }
  end

  -- Helper to safely get a function from telescope_fns
  local function get_ts_fn(name, default_desc)
    if telescope_fns and telescope_fns[name] then
      return telescope_fns[name]
    else
      logger.warn("Telescope function '" .. name .. "' not found in 'functions.telescope'. Keymap for '" .. default_desc .. "' will be a no-op or log a warning.")
      return function() logger.warn("Action for '"..default_desc.."' is not available (missing functions.telescope."..name..").") end
    end
  end

  local telescope_mappings = {
    ["<leader>f"] = {
      name = (icons.ui.search or "") .. " Find/Telescope",
      f = { get_ts_fn("find_files", "Find Files"), (icons.ui.file or "") .. " Find Files" },
      r = { get_ts_fn("recent_files", "Recent Files"), (icons.ui.file or "") .. " Recent Files" },
      g = { get_ts_fn("live_grep", "Live Grep"), (icons.misc.grep or "󱎸") .. " Live Grep" },
      b = { get_ts_fn("buffers", "Open Buffers"), (icons.misc.buffer or "󰓩") .. " Open Buffers" },
      m = { get_ts_fn("marks", "Marks"), (icons.misc.mark or "󰃀") .. " Marks" },
      h = { get_ts_fn("help_tags", "Help Tags"), (icons.misc.help or "") .. " Help Tags" },
      k = { get_ts_fn("keymaps", "Keymaps"), (icons.misc.keymap or "󰌌") .. " Keymaps" },
      c = { get_ts_fn("config_files", "Config Files"), (icons.misc.config or "󰒓") .. " Config Files" },
      d = { get_ts_fn("dotfiles", "Dotfiles"), (icons.misc.config or "󰒓") .. " Dotfiles" },
      C = { get_ts_fn("commands", "Commands"), (icons.misc.command or "") .. " Commands" },
      p = { get_ts_fn("projects", "Projects"), (icons.misc.project or "") .. " Projects" },
      s = { get_ts_fn("current_buffer_fuzzy_find", "Search in Buffer"), (icons.ui.fuzzy or "󰍉") .. " Search in Buffer" },
      t = { get_ts_fn("treesitter", "Treesitter Symbols"), (icons.misc.tree or "") .. " Treesitter Symbols" },
    },
    -- Assuming <leader>l is for LSP, and Telescope LSP actions are grouped there.
    -- If you want specific Telescope LSP finders under <leader>l, they should be in keymaps.which-key.lsp.lua
    -- or this file could register them under <leader>lf (leader-find-lsp-*) for example.
    -- For now, keeping it as in your original structure.
    ["<leader>l"] = { -- This might conflict if keymaps.which-key.lsp.lua also defines <leader>l group.
                     -- It's better if one module "owns" the <leader>l group.
      name = (icons.ui.code or "󰘧") .. " LSP (Telescope Finders)", -- Clarify this is for Telescope's LSP finders
      s = { get_ts_fn("document_symbols", "Document Symbols"), (icons.misc.symbol or "󰯻") .. " Document Symbols" },
      S = { get_ts_fn("workspace_symbols", "Workspace Symbols"), (icons.misc.symbol or "󰯻") .. " Workspace Symbols" },
      -- Add other LSP-related telescope pickers here if desired under <leader>l
      -- e.g., references, implementations, definitions via telescope
      -- Example:
      -- r = { get_ts_fn("lsp_references", "LSP References"), icons.lsp.References .. " LSP References" },
    },
  }

  local reg_ok, reg_err = pcall(wk_instance.register, telescope_mappings)
  if not reg_ok then
    logger.error("Failed to register Telescope mappings with which-key: " .. tostring(reg_err))
    return false
  end

  -- Handling advanced commands / filter mappings
  -- This part of your original code was a bit complex and might be better integrated
  -- directly into functions.telescope.lua or simplified.
  -- For now, I'll keep the structure but ensure it uses the logger.

  local filter_mappings_to_register = {}
  local function setup_advanced_command(name, fn_key_in_telescope_fns, display_name, opts)
    if not telescope_fns or not telescope_fns[fn_key_in_telescope_fns] then
      logger.warn("Telescope function '" .. fn_key_in_telescope_fns .. "' not found for advanced mapping: " .. display_name)
      return
    end
    -- which-key expects a list of tables, where each table is {key, command, desc, ...}
    -- This setup_advanced_command was creating filter_mappings[name] = {fn, name, opts}
    -- which is not directly registerable by which-key unless 'name' is the key sequence.
    -- Assuming 'name' here is a descriptive key for the command, not the <leader> sequence.
    -- These would need a <leader> sequence to be registered by which-key.
    -- For now, this part is commented out as its registration logic with which-key is unclear.
    -- If these are commands you call programmatically or via other mappings, this is fine.
    -- If they need to appear in which-key, they need a proper LHS key sequence.
    logger.debug("Advanced command defined (not registered with which-key unless explicitly given a key sequence): " .. display_name)
  end

  -- Example from your code (needs a key sequence for which-key)
  -- setup_advanced_command("GrepInProject", "live_grep", "Grep In Project", { cwd = get_ts_fn("get_project_root", "Get Project Root") })
  -- setup_advanced_command("FindAllDocs", "find_files", "Find All Docs", { find_command = {"rg", "--files", "--glob", "*.{md,txt,pdf}"} })

  -- If you intend to register these with specific keys:
  -- local advanced_wk_mappings = {
  --   {"<leader>fga", { get_ts_fn("live_grep", "Grep In Project"), opts = { cwd = get_ts_fn("get_project_root", "Get Project Root") } }, desc = "Grep In Project (Advanced)"},
  -- }
  -- wk_instance.register(advanced_wk_mappings)

  logger.info("Telescope keymaps registered successfully.")
  return true
end

-- Functions like M.reload and M.list_mappings are utilities for this module.
-- They are fine as they are, assuming they use the passed logger if adapted.

function M.reload(wk_instance, logger)
  if not logger then logger = { info = function(m) print("INFO [KWTELE_FB_RELOAD]: "..m) end } end
  logger.info("Reloading Telescope keymap configurations for which-key...")
  return M.register(wk_instance, logger)
end

function M.list_mappings(logger)
  if not logger then logger = { info = function(m) print("INFO [KWTELE_FB_LIST]: "..m) end, error = function(m) print("ERROR [KWTELE_FB_LIST]: "..m) end } end
  local ok, telescope_builtin = pcall(require, "telescope.builtin")
  if not ok then
    logger.error("Telescope not available to list mappings. Error: " .. tostring(telescope_builtin))
    return
  end
  logger.info("Showing Telescope keymaps (via telescope.builtin.keymaps)...")
  telescope_builtin.keymaps({ filter = "Telescope" }) -- This shows telescope's own keymaps, not necessarily what which-key shows.
end

return M

