-- lua/keymaps/definitions/keymaps.lua
local M = {}

function M.get_mappings(icons, logger)
  -- prefix será <leader>k (configurado no módulo_list)
  return {
    -- Nome do grupo
    k = { name = (icons.ui and icons.ui.Keyboard or "⌨") .. " Keymaps" },
    -- Dentro do grupo, tecla 'c' para checar os módulos
    c = { function() require("scripts.check_keymap_modules") end, "🔍 Checar módulos" },
    -- Aqui você pode adicionar outros atalhos relacionados a keymaps
    -- e.g.: l = { "<cmd>e ~/.config/nvim/lua/keymaps/init.lua<cr>", "✏️ Editar orquestrador" },
  }
end
return M


