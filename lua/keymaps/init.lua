-- keymaps/init.lua
-- Central orchestrator for which-key mappings
local M = {}

-- Initialize logger
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = ok_dbg and type(dbg.get_logger) == "function" 
  and dbg.get_logger("keymaps")
  or {
    info    = function(m) print("ℹ️  [keymaps] " .. m) end,
    warn    = function(m) print("⚠️  [keymaps] " .. m) end,
    error   = function(m) print("❌ [keymaps] " .. m) end,
    debug   = function(m) print("🐞 [keymaps] " .. m) end,
    success = function(m) print("✅ [keymaps] " .. m) end,
  }

-- Safe require helper
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    logger.debug("Failed to require: " .. module)
    return nil
  end
  return result
end

-- Load icons for UI enhancement
local icons = safe_require("utils.icons") or {}
local ui_ic = icons.ui or {}

-- Define prefix groups with icons (Which-Key)
local prefix_groups = {
  ["<leader>"]          = (ui_ic.Keyboard or "⌨")    .. " Main Actions",
  ["<leader>b"]  = (ui_ic.Tab or "󰓩")         .. " Buffers",
  ["<leader>c"]  = (icons.misc and icons.misc.Copilot or "") .. " Code/AI",
  ["<leader>d"]  = (icons.diagnostics and icons.diagnostics.Bug or "") .. " Debug/Diagnostics",
  ["<leader>e"]  = (ui_ic.FolderOpen or "") .. " Explorer",
  ["<leader>f"]  = (ui_ic.Search or "")     .. " Find/Files",
  ["<leader>g"]  = (icons.git and icons.git.Repo or "") .. " Git",
  ["<leader>l"]  = (icons.misc and icons.misc.LSP or "") .. " LSP",
  ["<leader>t"]  = (ui_ic.Terminal or "")    .. " Terminal",
  ["<leader>x"]  = (icons.diagnostics and icons.diagnostics.Warn or "") .. " Trouble/Extra",
  ["<leader>q"]  = (ui_ic.Exit or "")       .. " Quit/Session",
}

-- Register diagnostic command
vim.api.nvim_create_user_command("KeymapDoctor", function()
  local path = vim.fn.stdpath("config") .. "/lua/scripts/check_keymap_modules.lua"
  local ok, err = pcall(dofile, path)
  if not ok then
    logger.error("Error running KeymapDoctor: " .. tostring(err))
  end
end, { desc = "🔍 Keymap modules diagnostic" })

vim.keymap.set("n", "<leader>K", "<cmd>KeymapDoctor<cr>",
  { desc = "🔍 Check keymap modules" }
)

-- Initialize Which-Key
local wk = safe_require("which-key")
if not wk then
  logger.error("which-key not found. Aborting orchestrator.")
  return
end

-- Register prefix group names
wk.register(vim.tbl_map(function(name)
  return { name = name }
end, prefix_groups))
logger.debug("Prefix groups registered.")

-- Load module list
local modules_source = safe_require("keymaps.modules_list")
if type(modules_source) ~= "table" then
  logger.error("Failed to load keymaps.module_list.")
  return
end

-- Sort modules for consistency
pcall(function() table.sort(modules_source, function(a, b) return a.path < b.path end) end)

-- Apply mappings from each module
for _, mod_info in ipairs(modules_source) do
  if type(mod_info) ~= "table" or type(mod_info.path) ~= "string" then
    logger.warn("Invalid entry in module_list: " .. vim.inspect(mod_info))
  else
    local path = mod_info.path
    local prefix = mod_info.prefix or "<leader>"
    
    logger.debug(string.format("Processing module: %s with prefix '%s'", path, prefix))
    
    local ok, mod = pcall(require, path)
    if not ok then
      logger.warn("Failed to load: " .. path)
    elseif type(mod.get_mappings) ~= "function" then
      logger.warn("get_mappings missing in: " .. path)
    else
      -- Support both function signatures (with or without params)
      local maps
      if debug.getinfo(mod.get_mappings).nparams > 0 then
        maps = mod.get_mappings(icons, logger)
      else
        maps = mod.get_mappings()
      end
      
      if type(maps) == "table" and next(maps) then
        -- Ensure descriptions
        for lhs, map in pairs(maps) do
          if type(map) == "table" and not map.desc then
            map.desc = "🔧 No description"
            logger.warn("Mapping without desc: " .. lhs)
          end
        end
        
        wk.register(maps, { prefix = prefix, name = prefix_groups[prefix] })
        logger.success("Registered: " .. path)
      else
        logger.debug("No mappings returned from: " .. path)
      end
    end
  end
end

logger.info("✔️  Which-Key orchestrator completed successfully.")

return M   
