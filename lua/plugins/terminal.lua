-- nvim/lua/plugins/terminal.lua
-- Plugin specification for toggleterm.nvim
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.terminal")) or fallback
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- dependencies = { "folke/which-key.nvim" }, -- Removido: which-key é gerido centralmente
    cmd = { "ToggleTerm", "TermExec", "ToggleTermSetName", "ToggleTermSendCurrentLine", "ToggleTermSendVisualSelection" },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return math.floor(vim.o.lines * 0.3)
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4)
        end
        return 20
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        width = function() return math.floor(vim.o.columns * 0.85) end,
        height = function() return math.floor(vim.o.lines * 0.85) end,
        winblend = 0,
        highlights = { border = "FloatBorder", background = "NormalFloat" },
      },
      auto_scroll = true,
      winbar = {
        enabled = false,
        name_formatter = function(term) return term.name end,
      },
    },
    config = function(_, opts_from_lazy)
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.terminal")
      else
        local fallback_logger_name = "[ToggleTermConfig_Fallback]"
        logger = {
          info = function(m) print(fallback_logger_name .. " INFO: " .. m) end,
          error = function(m) print(fallback_logger_name .. " ERROR: " .. m) end,
          warn = function(m) print(fallback_logger_name .. " WARN: " .. m) end,
          debug = function(m) print(fallback_logger_name .. " DEBUG: " .. m) end,
        }
        logger.warn("Módulo 'core.debug.logger' ou função 'get_logger' não encontrados. Usando logger fallback para a configuração do toggleterm.")
      end

      logger.info("Configuring akinsho/toggleterm.nvim...")

      local toggleterm_ok, toggleterm = pcall(require, "toggleterm")
      if not toggleterm_ok then
        logger.error("Falha ao carregar o módulo 'toggleterm'. Configuração abortada. Erro: " .. tostring(toggleterm))
        return
      end

      toggleterm.setup(opts_from_lazy)
      logger.debug("toggleterm.setup(opts) concluído.")

      local term_map_opts_base = { noremap = true, silent = true }
      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Sair do Modo de Inserção" }))
      vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Janela Esquerda" }))
      vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Janela Abaixo" }))
      vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Janela Acima" }))
      vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Janela Direita" }))
      logger.debug("Mapeamentos de teclas do modo terminal para navegação e saída configurados.")

      -- REMOVIDO: Bloco de registo de keymaps do ToggleTerm com which-key.
      -- Esta responsabilidade foi movida para o orquestrador de keymaps (lua/keymaps/init.lua)
      -- e para o ficheiro de definição (lua/keymaps/definitions/terminal.lua).
      logger.info("akinsho/toggleterm.nvim configurado com sucesso. O registo de keymaps com which-key será tratado centralmente.")
    end,
  },
}
