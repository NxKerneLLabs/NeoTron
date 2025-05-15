-- Caminho Sugerido: lua/keymaps/definitions/nvimtree.lua
-- (Anteriormente: nvim/lua/keymaps/which-key/nvimtree.lua)

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/NvimTree] Gerando mapeamentos para NvimTree...")

  local nt_ok, nt_api = pcall(require, "nvim-tree.api")
  if not nt_ok then
    logger.error("[Defs/NvimTree] 'nvim-tree.api' não encontrado. Erro: " .. tostring(nt_api))
    -- nt_api será nil, safe_call lidará com isso.
  end

  local ui_icons = (icons and icons.ui) or {}

  local explorer_icon   = ui_icons.FolderOpen   or ""
  local actions_icon    = ui_icons.FolderCog    or ""
  local vsplit_icon     = ui_icons.SplitRight   or "│"
  local hsplit_icon     = ui_icons.SplitDown    or "─"
  local tab_icon        = ui_icons.Tab          or "󰓩"
  local edit_icon       = ui_icons.Edit         or ""
  local focus_icon      = ui_icons.Folder       or ""
  local refresh_icon    = ui_icons.Refresh      or ""
  local close_icon      = ui_icons.Close        or ""
  local fs_icon         = ui_icons.Wrench       or ""
  local create_icon     = ui_icons.Plus         or ""
  local delete_icon     = ui_icons.BoldClose    or ""
  local rename_icon     = ui_icons.Pencil       or ""
  local cut_icon        = ui_icons.Cut          or ""
  local paste_icon      = ui_icons.Clipboard    or ""
  local copy_icon       = ui_icons.Copy         or ""

  local function safe_call(fn_path, ...)
    if not nt_api then
      logger.warn("[Defs/NvimTree] API do NvimTree não disponível para chamar: " .. fn_path)
      return
    end
    local parts = vim.split(fn_path, "%.")
    local fn = nt_api
    for _, p in ipairs(parts) do
      fn = fn[p]
      if not fn then
        logger.error("[Defs/NvimTree] API NvimTree não encontrada: nvim-tree.api." .. fn_path)
        return
      end
    end
    if type(fn) == "function" then
      local ok, err = pcall(fn, ...)
      if not ok then
        logger.error("[Defs/NvimTree] Erro ao chamar nvim-tree.api." .. fn_path .. ": " .. tostring(err))
      end
    else
      logger.error("[Defs/NvimTree] nvim-tree.api." .. fn_path .. " não é uma função.")
    end
  end

  -- Estes mapeamentos incluem os prefixos <leader>e, <leader>en, <leader>ef.
  -- O orquestrador deve registrar este módulo com prefix = "".
  -- O nome do grupo <leader>e é definido em `plugins/which-key.lua`.
  local mappings = {
    ["<leader>e"] = {
      -- A ação para <leader>e (toggle) e os subgrupos n e f.
      -- O `name` para o grupo <leader>e em si é definido em `plugins/which-key.lua`.
      -- Se você quiser que <leader>e sozinho faça algo, defina uma chave vazia "" ou uma chave específica.
      [""] = { function() safe_call("tree.toggle") end, desc = explorer_icon .. " Toggle Explorer" }, -- Ação para <leader>e

      n = { -- Subgrupo <leader>en
        name = actions_icon .. " Tree Actions",
        s = { function() safe_call("node.open.vertical") end,   desc = vsplit_icon .. " Open Vertical Split" },
        v = { function() safe_call("node.open.horizontal") end, desc = hsplit_icon .. " Open Horizontal Split" },
        t = { function() safe_call("node.open.tab") end,        desc = tab_icon .. " Open in New Tab" },
        o = { function() safe_call("node.open.edit") end,       desc = edit_icon .. " Open Node (Edit)" },
        F = { function() safe_call("tree.focus") end,           desc = focus_icon .. " Focus Tree" },
        R = { function() safe_call("tree.reload") end,          desc = refresh_icon .. " Refresh Tree" },
        q = { function() safe_call("tree.close") end,           desc = close_icon .. " Close Tree" },
      },
      f = { -- Subgrupo <leader>ef
        name = fs_icon .. " FS Actions",
        c = { function() safe_call("fs.create") end,            desc = create_icon .. " Create Node" },
        d = { function() safe_call("fs.remove") end,            desc = delete_icon .. " Delete Node" },
        r = { function() safe_call("fs.rename") end,            desc = rename_icon .. " Rename Node" },
        x = { function() safe_call("fs.cut") end,               desc = cut_icon .. " Cut Node" },
        p = { function() safe_call("fs.paste") end,             desc = paste_icon .. " Paste Node" },
        Y = { function() safe_call("fs.copy.node") end,         desc = copy_icon .. " Copy Node Name" },
        A = { function() safe_call("fs.copy.absolute_path") end, desc = copy_icon .. " Copy Absolute Path" },
        R = { function() safe_call("fs.copy.relative_path") end, desc = copy_icon .. " Copy Relative Path" }, -- Cuidado: <leader>efR vs <leader>enR
      },
    },
  }

  logger.debug("[Defs/NvimTree] Mapeamentos gerados.")
  return mappings
end

return M
