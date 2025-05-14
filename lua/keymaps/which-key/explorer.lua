-- nvim/lua/keymaps/which-key/explorer.lua
-- Registers nvim-tree keybindings with which-key.nvim using nested prefixes.

local M = {}

function M.register(wk_instance, logger)
  -- Fallback logger
  if not logger then
    print("ERROR [keymaps.which-key.explorer]: Logger not provided. Using fallback.")
    logger = {
      info  = function(msg) print("INFO [KWEXP_FB]: "  .. msg) end,
      warn  = function(msg) print("WARN [KWEXP_FB]: "  .. msg) end,
      error = function(msg) print("ERROR [KWEXP_FB]: " .. msg) end,
      debug = function(msg) print("DEBUG [KWEXP_FB]: " .. msg) end,
    }
  end

  if not wk_instance or not wk_instance.register then
    logger.error("which-key instance not provided. Cannot register explorer keymaps.")
    return
  end

  -- Attempt to load nvim-tree API
  local nt_ok, nt_api = pcall(require, "nvim-tree.api")
  if not nt_ok then
    logger.error("'nvim-tree.api' not found. Some mappings may not work. Error: " .. tostring(nt_api))
  end

  -- Load icons with fallbacks
  local icons_ok, icons = pcall(require, "utils.icons")
  icons = icons_ok and icons or { ui = {} }
  icons.ui = icons.ui or {}

  -- Icon definitions
  local explorer_icon   = icons.ui.FolderOpen    or ""
  local actions_icon    = icons.ui.FolderCog     or ""
  local vsplit_icon     = icons.ui.SplitRight    or "│"
  local hsplit_icon     = icons.ui.SplitDown     or "─"
  local tab_icon        = icons.ui.Tab           or "󰓩"
  local edit_icon       = icons.ui.Edit          or ""
  local focus_icon      = icons.ui.Folder        or ""
  local refresh_icon    = icons.ui.Refresh       or ""
  local close_icon      = icons.ui.Close         or ""
  local fs_icon         = icons.ui.Wrench        or ""
  local create_icon     = icons.ui.Plus          or ""
  local delete_icon     = icons.ui.BoldClose     or ""
  local rename_icon     = icons.ui.Pencil        or ""
  local cut_icon        = icons.ui.Cut           or ""
  local paste_icon      = icons.ui.Clipboard     or ""
  local copy_icon       = icons.ui.Copy          or ""

  -- Helper for safe API calls
  local function safe_call(fn_path, ...)
    if not nt_api then return end
    local parts = vim.split(fn_path, "%.")
    local fn = nt_api
    for _, p in ipairs(parts) do
      fn = fn[p]
      if not fn then
        logger.error("nvim-tree API not found: " .. fn_path)
        return
      end
    end
    if type(fn) == "function" then
      local ok, err = pcall(fn, ...)
      if not ok then
        logger.error("Error calling nvim-tree." .. fn_path .. ": " .. tostring(err))
      end
    end
  end

  -- 1) Register the “Explorer” group label under <leader>e
  local ok1, err1 = pcall(function()
    wk_instance.register({
      e = { name = explorer_icon .. " Explorer (nvim-tree)" },
    }, { prefix = "<leader>" })
  end)
  if not ok1 then
    logger.error("Failed to register <leader>e group: " .. tostring(err1))
  end

  -- 2) Register the toggle command as <leader>e
  local ok2, err2 = pcall(function()
    wk_instance.register({
      e = { function() safe_call("tree.toggle") end, desc = explorer_icon .. " Toggle Explorer" },
    }, { prefix = "<leader>" })
  end)
  if not ok2 then
    logger.error("Failed to register <leader>e toggle: " .. tostring(err2))
  end

  -- 3) Register “Tree Actions” under <leader>en
  local ok3, err3 = pcall(function()
    wk_instance.register({
      n = { name = actions_icon .. " Tree Actions" },
      s = { function() safe_call("node.open.vertical") end,   desc = vsplit_icon .. " Open Vertical Split"   },
      v = { function() safe_call("node.open.horizontal") end, desc = hsplit_icon .. " Open Horizontal Split" },
      t = { function() safe_call("node.open.tab") end,        desc = tab_icon    .. " Open in New Tab"        },
      o = { function() safe_call("node.open.edit") end,       desc = edit_icon   .. " Open Node (Edit)"      },
      F = { function() safe_call("tree.focus") end,           desc = focus_icon  .. " Focus Tree"            },
      R = { function() safe_call("tree.reload") end,          desc = refresh_icon.. " Refresh Tree"          },
      q = { function() safe_call("tree.close") end,           desc = close_icon  .. " Close Tree"            },
    }, { prefix = "<leader>en" })
  end)
  if not ok3 then
    logger.error("Failed to register <leader>en mappings: " .. tostring(err3))
  end

  -- 4) Register “FS Actions” under <leader>ef
  local ok4, err4 = pcall(function()
    wk_instance.register({
      f = { name = fs_icon .. " FS Actions" },
      c = { function() safe_call("fs.create") end,           desc = create_icon .. " Create Node"       },
      d = { function() safe_call("fs.remove") end,           desc = delete_icon .. " Delete Node"       },
      r = { function() safe_call("fs.rename") end,           desc = rename_icon .. " Rename Node"       },
      x = { function() safe_call("fs.cut") end,              desc = cut_icon    .. " Cut Node"          },
      p = { function() safe_call("fs.paste") end,            desc = paste_icon  .. " Paste Node"        },
      Y = { function() safe_call("fs.copy.node") end,        desc = copy_icon   .. " Copy Node Name"    },
      A = { function() safe_call("fs.copy.absolute_path") end, desc = copy_icon .. " Copy Absolute Path"},
      R = { function() safe_call("fs.copy.relative_path") end, desc = copy_icon .. " Copy Relative Path"},
    }, { prefix = "<leader>ef" })
  end)
  if not ok4 then
    logger.error("Failed to register <leader>ef mappings: " .. tostring(err4))
  end

  logger.info("nvim-tree which-key mappings complete.")
end

return M
