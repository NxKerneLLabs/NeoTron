-- Caminho: lua/keymaps/definitions/telescope.lua

local function safe_require(mod)
  local ok, res = pcall(require, mod)
  return ok and res or nil
end

local M = {}

--- Gera os mapeamentos do Telescope sob o prefixo <leader>.
--- Retorna uma tabela de which-key em estrutura de grupos.
function M.get_mappings(icons, logger)
  logger = logger or { debug = print, warn = print, error = print, info = print }
  logger.debug("[Defs/Telescope] Iniciando geração de mapeamentos...")

  local ts = safe_require("functions.telescope") or {}
  local ui = icons.ui or {}
  local misc = icons.misc or {}
  local lsp = icons.lsp or {}

  local function picker(name, desc)
    if ts[name] then return ts[name] end
    return function()
      logger.warn(string.format("[Defs/Telescope] Picker '%s' não disponível", name))
    end
  end

  -- Definição de grupos 'f' (Find) e 'l' (LSP finders)
  local mappings = {
    f = {
      name = (ui.Search or "") .. " Find/Telescope",
      f = { picker("find_files"),     desc = (ui.Files or "") .. " Find Files" },
      r = { picker("recent_files"),   desc = (ui.Clock or "") .. " Recent Files" },
      g = { picker("live_grep"),      desc = (misc.Grep or "󱎸") .. " Live Grep" },
      b = { picker("buffers"),         desc = (misc.List or "") .. " Buffers" },
      h = { picker("help_tags"),      desc = (ui.InfoCircle or "") .. " Help Tags" },
      s = { picker("current_buffer_fuzzy_find"), desc = (ui.Fuzzy or "󰍉") .. " Search Buffer" },
      t = { picker("treesitter"),     desc = (misc.Tree or "") .. " Treesitter Symbols" },
      p = { picker("projects"),       desc = (misc.Project or "") .. " Projects" },
    },
    l = {
      name = (lsp.LSP or "") .. " LSP Finders",
      s = { picker("document_symbols"),  desc = (lsp.Definition or "") .. " Document Symbols" },
      S = { picker("workspace_symbols"), desc = (lsp.References or "󰌷") .. " Workspace Symbols" },
      -- adicione mais pickers LSP se desejar
    },
  }

  logger.debug("[Defs/Telescope] Mapeamentos gerados com sucesso.")
  return mappings
end

return M

