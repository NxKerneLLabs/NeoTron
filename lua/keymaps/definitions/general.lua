-- Arquivo: lua/keymaps/definitions/general.lua (VERSÃO CORRIGIDA E ALINHADA)
-- Define mapeamentos gerais para o which-key.

local M = {}

-- Esta função é chamada pelo orquestrador (lua/keymaps/init.lua)
-- Deve retornar uma tabela de mapeamentos no formato que o which-key.nvim espera.
function M.get_mappings(icons, logger)
  logger.debug("[Defs/General] Gerando mapeamentos gerais...")

  local ui_icons = (icons and icons.ui) or {}
  local save_icon = ui_icons.Save or ""
  local exit_icon = ui_icons.Exit or ""
  local settings_icon = ui_icons.Settings or ""
  local clear_icon = ui_icons.BoldClose or ""
  -- local leader_icon = ui_icons.Keyboard or "⌨" -- Ícone para o grupo principal <leader> já é definido em plugins/which-key.lua

  -- Estes mapeamentos são para o which-key.
  -- O prefixo <leader> já está incluído no LHS (Left Hand Side) do mapeamento.
  -- O orquestrador (`lua/keymaps/init.lua`) deve registar este módulo sem adicionar um prefixo global.
  local mappings = {
    -- Mapeamentos diretamente sob <leader> (sem outra letra de prefixo de grupo)
    -- O nome do grupo para <leader> em si ("Main Actions") é definido em plugins/which-key.lua
    { "<leader>w", "<cmd>write<cr>", desc = save_icon .. " Salvar Arquivo" },
    { "<leader>W", "<cmd>wall<cr>", desc = save_icon .. " Salvar Todos" },

    -- Mapeamentos que começam com <leader>q (Quit/Session)
    -- O nome do grupo para <leader>q ("Quit/Session") é definido em plugins/which-key.lua
    { "<leader>qq", "<cmd>quit<cr>", desc = exit_icon .. " Sair do Buffer Atual" },
    { "<leader>qQ", "<cmd>qa!<cr>", desc = exit_icon .. " Sair de Tudo (Forçado)!" },
    -- Se tiveres outros mapeamentos para <leader>q, adiciona-os aqui. Ex:
    -- { "<leader>qs", "<cmd>mksession!<cr>", desc = "Salvar Sessão" },

    -- Outros mapeamentos gerais
    { "<leader>nh", "<cmd>noh<cr>", desc = clear_icon .. " Limpar Highlight da Busca" },
    { "<leader>rc", "<cmd>e $MYVIMRC<cr>", desc = settings_icon .. " Editar Config Neovim" },
    { "<leader>rR", "<cmd>source $MYVIMRC<cr>", desc = settings_icon .. " Recarregar Config Neovim" },

    -- Exemplo de um sub-grupo DENTRO de general, se necessário (não recomendado se já tens grupos principais)
    -- { "<leader>z", group = "Zen Mode" },
    -- { "<leader>zz", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
  }

  logger.debug("[Defs/General] Mapeamentos gerais gerados: " .. vim.inspect(mappings))
  return mappings
end

return M

