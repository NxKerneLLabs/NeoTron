-- Caminho: lua/ui/misc.lua
-- Este arquivo deve retornar uma LISTA de especificações de plugins para lazy.nvim

-- Obtain a namespaced logger from core.debug for this module file itself
local logger
local core_debug_ok, core_debug = pcall(require, "core.debug")
if core_debug_ok and core_debug and core_debug.get_logger then
  logger = core_debug.get_logger("ui.misc_specs") -- Logger for this spec file
else
  logger = { -- Fallback básico
    info = function(msg) vim.notify("UI_MISC_SPEC INFO: " .. msg, vim.log.levels.INFO) end,
    error = function(msg) vim.notify("UI_MISC_SPEC ERROR: " .. msg, vim.log.levels.ERROR) end,
    warn = function(msg) vim.notify("UI_MISC_SPEC WARN: " .. msg, vim.log.levels.WARN) end,
    debug = function(msg) vim.notify("UI_MISC_SPEC DEBUG: " .. msg, vim.log.levels.DEBUG) end,
  }
  if not core_debug_ok then
    logger.error("core.debug module not found. Using fallback logger. Error: " .. tostring(core_debug))
  elseif not core_debug.get_logger then
     logger.error("core.debug.get_logger function not found. Using fallback logger.")
  end
end

return {
  -- Indentação visual com indent-blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { -- Pass options directly to lazy.nvim opts, ibl will use them in its setup
      indent = {
        char = "│", -- Alternative: "▏" (thin), "┆" (dashed)
        tab_char = "│",
        -- highlight = "IndentBlanklineIndent1", -- Uses default highlight unless specified
        -- context_highlight = "IndentBlanklineContextChar",
        -- show_trailing_blankline_indent = false,
      },
      scope = {
        enabled = true,
        show_start = false, -- Shows marker at the start of the scope
        show_end = false,   -- Shows marker at the end of the scope
        char = "│",       -- Character for the scope line
        --highlight = "IndentBlanklineScope", -- Highlight for the scope line
        -- include = { node_type = { ['*'] = {'argument_list', 'parameters', 'parenthesized_expression'} } }
      },
      exclude = {
        filetypes = {
          "help", "alpha", "dashboard", "neo-tree", "NvimTree",
          "Trouble", "trouble", "lazy", "mason", "notify",
          "toggleterm", "lazyterm", "terminal", "packer", "oil",
          "aerial", "starter"
        },
        buftypes = { "nofile", "prompt", "quickfix", "terminal" },
      },
      -- space_char_blankline = " ", -- Show space character on blank lines
      -- show_current_context = true,
      -- show_current_context_start = true,
    },
    config = function(_, opts_from_lazy) -- opts_from_lazy are the values from the 'opts' table above
      local plugin_logger
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger = core_debug.get_logger("plugins.indent-blankline")
      else
        plugin_logger = logger; plugin_logger.error("core.debug.get_logger not found for indent-blankline.")
      end
      plugin_logger.info("Configuring lukas-reineke/indent-blankline.nvim...")
      local ibl_ok, ibl = pcall(require, "ibl")
      if not ibl_ok then
        plugin_logger.error("Failed to load 'ibl' for indent-blankline. Error: " .. tostring(ibl))
        return
      end
      ibl.setup(opts_from_lazy)
      plugin_logger.info("indent-blankline.nvim configured.")
    end,
  },

  -- Ícones para a UI (dependência comum para muitos plugins de UI)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true, -- Load only when needed by another plugin
    config = function()
      local plugin_logger_di
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger_di = core_debug.get_logger("plugins.nvim-web-devicons")
      else
        plugin_logger_di = logger; plugin_logger_di.error("core.debug.get_logger not found for nvim-web-devicons.")
      end
      plugin_logger_di.info("nvim-web-devicons loaded (on demand).")
      -- No explicit setup needed unless overriding icons.
      -- require('nvim-web-devicons').setup { override = { lua = { icon = "", color = "#51a0cf", name = "Lua" } } }
    end,
  },

  -- Biblioteca de UI (dependência para alguns plugins)
  {
    "MunifTanjim/nui.nvim",
    lazy = true, -- Load only when needed
    config = function()
      local plugin_logger_nui
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger_nui = core_debug.get_logger("plugins.nui")
      else
        plugin_logger_nui = logger; plugin_logger_nui.error("core.debug.get_logger not found for nui.nvim.")
      end
      plugin_logger_nui.info("nui.nvim loaded (on demand).")
    end
  },

  -- Minimalist icon provider (alternative or supplement to nvim-web-devicons)
  {
    "echasnovski/mini.icons",
    lazy = true, -- Load when needed
    -- opts = {}, -- mini.icons options if any direct setup needed
    init = function() -- init runs before setup/config
      -- Optional: Mock nvim-web-devicons if other plugins strictly depend on it
      -- and you prefer mini.icons as the primary provider.
      -- Check mini.icons documentation for the latest recommended way.
      if package.preload["nvim-web-devicons"] == nil then
        package.preload["nvim-web-devicons"] = function()
          local mini_icons_ok, mini_icons = pcall(require, "mini.icons")
          if mini_icons_ok and mini_icons then
            mini_icons.mock_nvim_web_devicons()
            return package.loaded["nvim-web-devicons"]
          end
          return nil -- Return nil if mini.icons itself fails to load
        end
      end
    end,
    config = function()
        local plugin_logger_mi
        if core_debug_ok and core_debug and core_debug.get_logger then
            plugin_logger_mi = core_debug.get_logger("plugins.mini.icons")
        else
            plugin_logger_mi = logger; plugin_logger_mi.error("core.debug.get_logger not found for mini.icons.")
        end
        plugin_logger_mi.info("mini.icons loaded (on demand).")
        -- require("mini.icons").setup() -- if mini.icons requires explicit setup with opts
    end,
  },

  -- Melhora inputs e dialogs da UI (vim.ui.input e vim.ui.select)
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    -- opts = {}, -- Can pass all dressing.setup options here directly
    config = function()
      local plugin_logger_dr
      if core_debug_ok and core_debug and core_debug.get_logger then
        plugin_logger_dr = core_debug.get_logger("plugins.dressing")
      else
        plugin_logger_dr = logger; plugin_logger_dr.error("core.debug.get_logger not found for dressing.nvim.")
      end
      plugin_logger_dr.info("Configuring stevearc/dressing.nvim...")

      local dressing_ok, dressing = pcall(require, "dressing")
      if not dressing_ok then
        plugin_logger_dr.error("Failed to load 'dressing' module. Error: " .. tostring(dressing))
        return
      end

      dressing.setup({
        input = {
          enabled = true,
          default_prompt = "➤ ",
          trim_prompt = true,
          title_pos = "left",
          insert_only = false,
          start_in_insert = true,
          border = "rounded",
          relative = "cursor",
          prefer_width = 40,
          min_width = 20,
          win_options = {
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
            winblend = 0,
          },
          -- keys = { ["<Esc>"] = "Close", ["<CR>"] = "Confirm" },
        },
        select = {
          enabled = true,
          backend = { "telescope", "fzf", "builtin" }, -- Order of preference
          trim_prompt = true,
          telescope = {}, -- Uses default Telescope theme/layout
          -- fzf = { window = { width = 0.5, height = 0.4 } },
          builtin = {
            border = "rounded",
            relative = "editor",
            win_options = {
              winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
              winblend = 0,
            },
            -- keys = { ["<Esc>"] = "Close", ["<CR>"] = "Confirm" },
          },
        },
      })
      plugin_logger_dr.info("dressing.nvim configured.")
    end,
  },
}

