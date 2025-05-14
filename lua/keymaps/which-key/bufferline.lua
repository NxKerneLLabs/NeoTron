-- nvim/lua/keymaps/which-key/bufferline.lua
-- Registers Bufferline keybindings with which-key.nvim.

local M = {}

function M.register(wk_instance, logger)
  -- Fallback logger if none provided
  if not logger then
    print("ERROR [keymaps.which-key.bufferline]: Logger not provided. Using fallback.")
    logger = {
      info  = function(msg) print("INFO [KWBL_FB]: "  .. msg) end,
      warn  = function(msg) print("WARN [KWBL_FB]: "  .. msg) end,
      error = function(msg) print("ERROR [KWBL_FB]: " .. msg) end,
      debug = function(msg) print("DEBUG [KWBL_FB]: " .. msg) end,
    }
  end

  if not wk_instance then
    logger.error("which-key instance not provided. Cannot register Bufferline keymaps.")
    return
  end

  -- Load icons (with text fallbacks)
  local icons_ok, icons = pcall(require, "utils.icons")
  local pick_icon          = ""
  local next_icon          = ""
  local prev_icon          = ""
  local close_icon         = ""
  local close_others_icon  = ""
  local sort_icon          = ""
  local buffer_icon        = ""

  if icons_ok and icons then
    icons.ui = icons.ui or {}
    pick_icon         = icons.ui.List       or pick_icon
    next_icon         = icons.ui.ArrowRight or next_icon
    prev_icon         = icons.ui.ArrowLeft  or prev_icon
    close_icon        = icons.ui.Close      or close_icon
    close_others_icon = icons.ui.BoldClose  or close_others_icon
    sort_icon         = icons.ui.Sort       or sort_icon
    buffer_icon       = icons.ui.Tab        or buffer_icon
  else
    logger.warn("'utils.icons' not found, using defaults. Error: " .. tostring(icons))
  end

  -- Define mappings *inside* <leader>b
  local bufferline_mappings = {
    p  = { "<cmd>BufferLinePick<cr>",           desc = pick_icon         .. " Pick Buffer"       },
    n  = { "<cmd>BufferLineCycleNext<cr>",      desc = next_icon         .. " Next Buffer"       },
    P  = { "<cmd>BufferLineCyclePrev<cr>",      desc = prev_icon         .. " Previous Buffer"   },
    c  = { "<cmd>bdelete<cr>",                  desc = close_icon        .. " Close Current"     },
    C  = { "<cmd>BufferLineCloseOthers<cr>",    desc = close_others_icon .. " Close Others"      },
    l  = { "<cmd>BufferLineCloseRight<cr>",     desc = close_icon        .. " Close to Right"    },
    h  = { "<cmd>BufferLineCloseLeft<cr>",      desc = close_icon        .. " Close to Left"     },
    s  = { "<cmd>BufferLineSortByDirectory<cr>",desc = sort_icon         .. " Sort by Directory" },
    S  = { "<cmd>BufferLineSortByExtension<cr>",desc = sort_icon         .. " Sort by Extension" },

    ["1"] = { "<cmd>BufferLineGoToBuffer 1<cr>",  desc = buffer_icon .. " Go to Buffer 1"   },
    ["2"] = { "<cmd>BufferLineGoToBuffer 2<cr>",  desc = buffer_icon .. " Go to Buffer 2"   },
    ["3"] = { "<cmd>BufferLineGoToBuffer 3<cr>",  desc = buffer_icon .. " Go to Buffer 3"   },
    ["0"] = { "<cmd>BufferLineGoToBuffer -1<cr>", desc = buffer_icon .. " Go to Last Buffer" },
  }

  -- Register under <leader>b with error handling
  local ok, err = pcall(function()
    wk_instance.register(bufferline_mappings, { prefix = "<leader>b" })
  end)

  if ok then
    logger.info("Bufferline keymaps registered under <leader>b")
  else
    logger.error("Error registering Bufferline mappings: " .. tostring(err))
  end
end

return M

