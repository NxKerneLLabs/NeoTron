-- nvim/lua/plugins/terminal.lua
-- Plugin specification for toggleterm.nvim

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*", -- Or specify a version like "v2.8.0"
    dependencies = { "folke/which-key.nvim" }, -- For registering which-key mappings
    cmd = { "ToggleTerm", "TermExec", "ToggleTermSetName", "ToggleTermSendCurrentLine", "ToggleTermSendVisualSelection" },
    -- event = "VeryLazy", -- Alternative lazy-loading strategy
    opts = { -- Configuration options passed to toggleterm.setup
      size = function(term)
        if term.direction == "horizontal" then
          return math.floor(vim.o.lines * 0.3) -- 30% of lines for horizontal
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4) -- 40% of columns for vertical
        end
        return 20 -- Default size for float or unhandled directions
      end,
      open_mapping = [[<C-\>]], -- Main mapping to toggle a terminal
      hide_numbers = true,    -- Hide line numbers in the terminal window
      shade_terminals = true, -- Shade inactive terminal windows
      shading_factor = 2,     -- How much to shade (1-5)
      start_in_insert = true, -- Start terminal in insert mode
      insert_mappings = true, -- Allow insert mode mappings in the terminal
      persist_size = true,    -- Remember size across sessions
      persist_mode = true,    -- Remember mode (normal/insert) when reopening
      direction = "float",    -- Default direction when using open_mapping
      close_on_exit = true,   -- Close the terminal window when the shell exits
      shell = vim.o.shell,    -- Use the system's default shell
      float_opts = {
        border = "curved", -- "none", "single", "double", "shadow", "curved"
        width = function() return math.floor(vim.o.columns * 0.85) end,
        height = function() return math.floor(vim.o.lines * 0.85) end,
        winblend = 0,      -- Transparency (0-100)
        highlights = { border = "FloatBorder", background = "NormalFloat" },
      },
      auto_scroll = true,     -- Automatically scroll to the bottom on new output
      winbar = {
        enabled = false,    -- Disable winbar for terminals by default
        name_formatter = function(term) return term.name end,
      },
      -- Example of predefined terminals:
      -- terms = {
      --   lazygit = { cmd = "lazygit", direction = "float", hidden = true, count = 5, esc_chars = false },
      --   node = { cmd = "node", direction = "vertical", count = 6 },
      -- },
    },
    config = function(_, opts_from_lazy) -- opts_from_lazy are the values from the 'opts' table above
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.terminal")
      else
        logger = { info = function(m) print("INFO [TermP_FB]: " .. m) end, error = function(m) print("ERROR [TermP_FB]: " .. m) end, warn = function(m) print("WARN [TermP_FB]: " .. m) end, debug = function(m) print("DEBUG [TermP_FB]: " .. m) end }
        logger.error("core.debug.get_logger not found. Using fallback for toggleterm config.")
      end

      logger.info("Configuring akinsho/toggleterm.nvim...")

      local toggleterm_ok, toggleterm = pcall(require, "toggleterm")
      if not toggleterm_ok then
        logger.error("Failed to load 'toggleterm' module. Setup aborted. Error: " .. tostring(toggleterm))
        return
      end

      toggleterm.setup(opts_from_lazy)
      logger.debug("toggleterm.setup(opts) completed.")

      -- Terminal mode keymaps for exiting and window navigation
      -- These are set directly as they are for terminal mode 't'
      local term_map_opts_base = { noremap = true, silent = true }

      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Exit Insert Mode" }))
      -- Consider using a single <Esc> to exit terminal insert mode if preferred,
      -- and then another key (like <C-q> or a leader key) to close the terminal window.
      -- <Esc><Esc> is a common pattern but can sometimes be slow if not handled well by terminal.

      -- Window navigation from terminal mode
      -- These allow using <C-w> + hjkl to navigate out of the terminal window
      -- by first exiting terminal mode (<C-\><C-n>) then issuing the window command.
      vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Window Left" }))
      vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Window Down" }))
      vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Window Up" }))
      vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", vim.tbl_deep_extend("force", term_map_opts_base, { desc = "Terminal: Window Right" }))
      logger.debug("Terminal mode keymaps for navigation and exit configured.")

      -- Register ToggleTerm related keymaps with which-key
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok and wk then
        local term_keymaps_module_ok, term_keymaps_module = pcall(require, "keymaps.which-key.terminal")
        if term_keymaps_module_ok and term_keymaps_module and type(term_keymaps_module.register) == "function" then
          local keymap_logger = (core_debug_ok and core_debug.get_logger) and core_debug.get_logger("keymaps.which-key.terminal") or logger
          term_keymaps_module.register(wk, keymap_logger) -- Pass logger
          logger.info("ToggleTerm keymaps registered with which-key.")
        else
          logger.warn("Failed to load or register ToggleTerm keymaps from 'keymaps.which-key.terminal'. Error or module structure issue: " .. tostring(term_keymaps_module))
        end
      else
        logger.warn("'which-key' module not available for ToggleTerm keymaps. Error: " .. tostring(wk))
      end
      logger.info("akinsho/toggleterm.nvim configured successfully.")
    end,
  },
}

