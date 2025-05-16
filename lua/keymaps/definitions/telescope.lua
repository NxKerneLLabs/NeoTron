-- Caminho: lua/keymaps/definitions/telescope.lua

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/Telescope] Gerando mapeamentos para Telescope...")

  local telescope_fns_ok, telescope_fns = pcall(require, "functions.telescope")
  if not telescope_fns_ok then
    logger.error("[Defs/Telescope] Falha ao carregar 'functions.telescope'. Erro: " .. tostring(telescope_fns))
    telescope_fns = {} -- Fallback
  end

  local ui_icons = (icons and icons.ui) or {}
  local misc_icons = (icons and icons.misc) or {}
  local lsp_icons_map = (icons and icons.lsp) or {}

  -- Função unificada para chamadas seguras de funções Telescope
  local function get_ts_fn(name, default_desc)
    if telescope_fns and telescope_fns[name] then
      return telescope_fns[name]
    else
      logger.warn("[Defs/Telescope] Função Telescope '" .. name .. "' não encontrada. Ação para '" .. default_desc .. "' será no-op.")
      return function()
        logger.warn("[Defs/Telescope] Ação para '" .. default_desc .. "' não disponível (functions.telescope." .. name .. " faltando).")
      end
    end
  end

  -- Estes mapeamentos incluem os prefixos <leader>f e <leader>l.
  -- O orquestrador deve registrar este módulo com prefix = "".
  -- Os NOMES dos grupos <leader>f e <leader>l devem ser definidos em `plugins/which-key.lua`.
  local mappings = {
    ["<leader>f"] = {
      f = { get_ts_fn("find_files", "Find Files"), desc = (ui_icons.file or ui_icons.Files or "") .. " Find Files" },
      r = { get_ts_fn("recent_files", "Recent Files"), desc = (ui_icons.file or ui_icons.Clock or "") .. " Recent Files" },
      g = { get_ts_fn("live_grep", "Live Grep"), desc = (misc_icons.grep or misc_icons.Grep or "󱎸") .. " Live Grep" },
      b = { get_ts_fn("buffers", "Open Buffers"), desc = (misc_icons.buffer or misc_icons.List or "󰓩") .. " Open Buffers" },
      m = { get_ts_fn("marks", "Marks"), desc = (misc_icons.mark or "󰃀") .. " Marks" },
      h = { get_ts_fn("help_tags", "Help Tags"), desc = (misc_icons.help or ui_icons.InfoCircle or "") .. " Help Tags" },
      k = { get_ts_fn("keymaps", "Keymaps"), desc = (misc_icons.keymap or "󰌌") .. " Keymaps" },
      c = { get_ts_fn("config_files", "Config Files"), desc = (misc_icons.config or "󰒓") .. " Config Files" },
      d = { get_ts_fn("dotfiles", "Dotfiles"), desc = (misc_icons.config or "󰒓") .. " Dotfiles" },
      C = { get_ts_fn("commands", "Commands"), desc = (misc_icons.command or "") .. " Commands" },
      p = { get_ts_fn("projects", "Projects"), desc = (misc_icons.project or misc_icons.Project or "") .. " Projects" },
      s = { get_ts_fn("current_buffer_fuzzy_find", "Search in Buffer"), desc = (ui_icons.fuzzy or ui_icons.Fuzzy or "󰍉") .. " Search in Buffer" },
      t = { get_ts_fn("treesitter", "Treesitter Symbols"), desc = (misc_icons.tree or misc_icons.Tree or "") .. " Treesitter Symbols" },
    },
    ["<leader>l"] = {
      -- Certifique-se de que não há conflitos de teclas com `definitions/lsp.lua`.
      -- Idealmente, todos os mapeamentos <leader>l ficariam em `definitions/lsp.lua`.
      -- Se houver conflitos, considere prefixos mais específicos como <leader>lf (find lsp) ou <leader>ls (search lsp).
      s = { get_ts_fn("document_symbols", "Document Symbols"), desc = (misc_icons.symbol or lsp_icons_map.Definition or "󰯻") .. " Document Symbols (TS)" },
      S = { get_ts_fn("workspace_symbols", "Workspace Symbols"), desc = (misc_icons.symbol or lsp_icons_map.References or "󰯻") .. " Workspace Symbols (TS)" },
    },
  }

  logger.debug("[Defs/Telescope] Mapeamentos gerados.")
  return mappings
end

-- Funções utilitárias como reload e list_mappings preservadas para uso externo.
function M.reload(wk_instance, logger_param)
  local log = logger_param or { info = function(m) print("INFO [Defs/TS_Reload_FB]: " .. m) end }
  log.info("Recarregando configurações de keymap do Telescope para which-key...")
  -- Esta função precisaria ser chamada com a instância do wk e logger se usada externamente.
  -- A lógica de registro foi removida desta função no contexto da refatoração.
  -- Para recarregar, você precisaria chamar o processo de registro do orquestrador novamente.
  return false -- Indicando que esta função não registra mais diretamente.
end

function M.list_mappings(logger_param)
  local log = logger_param or { info = function(m) print("INFO [Defs/TS_List_FB]: " .. m) end, error = function(m) print("ERROR [Defs/TS_List_FB]: " .. m) end }
  local ok, telescope_builtin = pcall(require, "telescope.builtin")
  if not ok then
    log.error("Telescope não disponível para listar mapeamentos. Erro: " .. tostring(telescope_builtin))
    return
  end
  log.info("Mostrando keymaps do Telescope (via telescope.builtin.keymaps)...")
  telescope_builtin.keymaps({ filter = "Telescope" })
end

return M
