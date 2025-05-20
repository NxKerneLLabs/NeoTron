-- Caminho Sugerido: lua/keymaps/definitions/bufferline.lua
-- (Anteriormente: nvim/lua/keymaps/which-key/definitions/bufferline.lua)

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/Bufferline] Gerando mapeamentos para Bufferline...")

  local ui_icons = (icons and icons.ui) or {}
  local pick_icon         = ui_icons.List         or ""
  local next_icon         = ui_icons.ArrowRight   or ""
  local prev_icon         = ui_icons.ArrowLeft    or ""
  local close_icon        = ui_icons.Close        or ""
  local close_others_icon = ui_icons.BoldClose    or ""
  local sort_icon         = ui_icons.Sort         or ""
  local buffer_icon       = ui_icons.Tab          or "" -- ou icons.ui.Buffer

  -- Estes mapeamentos são para serem registrados COM o prefixo "<leader>b"
  -- pelo orquestrador. As chaves são as letras finais.
  local mappings = {
    { "p", "<cmd>BufferLinePick<cr>",          desc = pick_icon .. " Pick Buffer" },
    { "n", "<cmd>BufferLineCycleNext<cr>",     desc = next_icon .. " Next Buffer" },
    { "P", "<cmd>BufferLineCyclePrev<cr>",     desc = prev_icon .. " Previous Buffer" },
    { "c", "<cmd>bdelete<cr>",                 desc = close_icon .. " Close Current" },
    { "C", "<cmd>BufferLineCloseOthers<cr>",   desc = close_others_icon .. " Close Others" },
    { "l", "<cmd>BufferLineCloseRight<cr>",    desc = close_icon .. " Close to Right" },
    { "h", "<cmd>BufferLineCloseLeft<cr>",     desc = close_icon .. " Close to Left" },
    { "s", "<cmd>BufferLineSortByDirectory<cr>", desc = sort_icon .. " Sort by Directory" },
    { "S", "<cmd>BufferLineSortByExtension<cr>", desc = sort_icon .. " Sort by Extension" },

    { "1", "<cmd>BufferLineGoToBuffer 1<cr>",  desc = buffer_icon .. " Go to Buffer 1" },
    { "2", "<cmd>BufferLineGoToBuffer 2<cr>",  desc = buffer_icon .. " Go to Buffer 2" },
    { "3", "<cmd>BufferLineGoToBuffer 3<cr>",  desc = buffer_icon .. " Go to Buffer 3" },
    { "0", "<cmd>BufferLineGoToBuffer -1<cr>", desc = buffer_icon .. " Go to Last Buffer" },
  }

  logger.debug("[Defs/Bufferline] Mapeamentos gerados.")
  return mappings
end

return M

