-- lua/keymaps/definitions/neo-tree.lua
local M = {}

local function safe_call(cmd, desc, logger)
  return function()
    local ok, err = pcall(vim.cmd, cmd)
    if not ok then logger.error("[NeoTree] Erro em '" .. desc .. "': " .. err) end
  end
end

function M.get_mappings(icons, logger)
  logger.debug("[NeoTree] Gerando mapeamentos...")

  local ui = icons.ui or {}
  local icons_map = {
    explorer = ui.FolderOpen or "📂",
    actions = ui.FolderCog or "⚙️",
    fs = ui.Wrench or "🔧",
    open = ui.Edit or "📝",
    close = ui.Close or "✖",
    refresh = ui.Refresh or "🔄",
    create = ui.Plus or "➕",
    delete = ui.BoldClose or "🗑️",
    rename = ui.Pencil or "✏️",
    copy = ui.Copy or "📋",
  }

  return {
    ["<leader>e"] = {
      [""] = { safe_call("Neotree toggle", "Toggle NeoTree", logger), desc = icons_map.explorer .. " Toggle Explorer" },
      n = {
        name = icons_map.actions .. " Tree Actions",
        o = { safe_call("Neotree focus", "Focus NeoTree", logger), desc = icons_map.open .. " Focus Tree" },
        r = { safe_call("Neotree refresh", "Refresh NeoTree", logger), desc = icons_map.refresh .. " Refresh" },
        q = { safe_call("Neotree close", "Close NeoTree", logger), desc = icons_map.close .. " Close" },
      },
      f = {
        name = icons_map.fs .. " FS Actions",
        c = { safe_call("Neotree action=add", "Create Node", logger), desc = icons_map.create .. " Create" },
        d = { safe_call("Neotree action=delete", "Delete Node", logger), desc = icons_map.delete .. " Delete" },
        r = { safe_call("Neotree action=rename", "Rename Node", logger), desc = icons_map.rename .. " Rename" },
        y = { safe_call("Neotree action=copy_to_clipboard", "Copy Node", logger), desc = icons_map.copy .. " Copy" },
      },
    },
  }
end

return M
