-- Location: nvim/lua/plugins/which-key.lua
return {
  {
    "folke/which-key.nvim",
    event = { "VeryLazy" },
    config = function()
      -- Setup logger (with fallback)
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.which-key")
      else
        logger = {
          info  = function(m) print("INFO [WK]: "  .. m) end,
          warn  = function(m) print("WARN [WK]: "  .. m) end,
          error = function(m) print("ERROR [WK]: " .. m) end,
          debug = function(m) print("DEBUG [WK]: " .. m) end,
        }
        logger.error("core.debug.get_logger not found. Using fallback logger.")
      end

      logger.info("Configuring folke/which-key.nvim...")

      -- Require which-key
      local wk_ok, wk = pcall(require, "which-key")
      if not wk_ok or not wk then
        logger.error("Failed to load 'which-key'. Skipping configuration: " .. tostring(wk))
        return
      end

      -- Load icons module (with fallback tables)
      local icons_ok, icons_mod = pcall(require, "utils.icons")
      local icons = { ui = {}, misc = {}, git = {}, diagnostics = {} }
      if icons_ok and icons_mod then
        icons = icons_mod
        icons.ui         = icons.ui         or {}
        icons.misc       = icons.misc       or {}
        icons.git        = icons.git        or {}
        icons.diagnostics= icons.diagnostics or {}
        logger.debug("utils.icons loaded for which-key.")
      else
        logger.warn("Failed to load 'utils.icons'. Using empty fallback. Error: " .. tostring(icons_mod))
      end

      -- Core setup for which-key
      wk.setup({
        plugins = {
          marks       = true,
          registers   = true,
          spelling    = { enabled = true, suggestions = 20 },
          presets     = { operators = false, windows = true, nav = true, z = true, g = true },
        },
        icons = {
          breadcrumb = (icons.ui.ChevronRight or "»") .. " ",
          separator  = (icons.ui.ArrowRight   or "→") .. " ",
          group      = (icons.ui.Plus         or "+") .. " ",
        },
        window = { border = "rounded", winblend = 0, title = true, title_pos = "center", padding = {1,2,1,2} },
        layout = { height = { min = 4, max = 25 }, width = { min = 20, max = 50 }, spacing = 6, align = "left" },
        show_help = true,
        replace_keycodes = { ["<leader>"] = "LDR", ["<space>"] = "SPC", ["<cr>"] = "ENT", ["<tab>"] = "TAB" },
        disable = { filetypes = {"TelescopePrompt","NvimTree","alpha","dashboard","lazy","mason"}, buftypes = {"terminal","nofile","prompt"} },
        filter = function(mapping)
          if mapping.desc and mapping.desc:find("VeryHidden", 1, true) then return false end
          if not mapping.lhs or mapping.lhs == "" then
            logger.warn("Filtering out mapping with empty LHS: " .. vim.inspect(mapping))
            return false
          end
          return true
        end,
      })
      logger.info("which-key.setup() completed.")

      -- Optionally wrap register for debug
      if core_debug_ok and core_debug and core_debug.wrap_register then
        wk.register = core_debug.wrap_register(wk.register, "which-key", "wk.register_wrapped")
        logger.debug("Wrapped wk.register with core.debug.wrap_register.")
      end

      -- Register only group names under <leader>
      local leader_key_group_names = {
        [""]  = { name = (icons.ui.Keyboard    or "⌨") .. " Main" },
        ["b"] = { name = (icons.ui.Tab         or "󰓩") .. " Buffers" },
        ["c"] = { name = (icons.misc.Copilot   or "") .. " Code/AI" },
        ["d"] = { name = (icons.misc.Bug       or "") .. " Debug/Diagnostics" },
        ["e"] = { name = (icons.ui.FolderOpen  or "") .. " Explorer" },
        ["f"] = { name = (icons.ui.Search      or "") .. " Find/Files" },
        ["g"] = { name = (icons.git.Repo       or "") .. " Git" },
        ["l"] = { name = (icons.misc.LSP       or "") .. " LSP" },
        ["t"] = { name = (icons.ui.Terminal    or "") .. " Terminal" },
        ["x"] = { name = (icons.diagnostics.Warn or "") .. " Trouble/Extra" },
        ["q"] = { name = (icons.ui.Exit        or "") .. " Quit/Session" },
      }

      logger.info("Registering global prefix group names for which-key...")
      local reg_ok, reg_err = pcall(function()
        wk.register(leader_key_group_names, { prefix = "<leader>" })
      end)
      if reg_ok then
        logger.info("Global prefix group names registered successfully.")
      else
        logger.error("Error registering prefix group names: " .. tostring(reg_err))
      end

      -- Load and register actual mappings
      local map_ok, map_mod = pcall(require, "keymaps.which-key.init")
      if map_ok and type(map_mod.setup_all_mappings) == "function" then
        logger.info("Calling setup_all_mappings from keymaps.which-key.init...")
        local ok_m, err_m = pcall(map_mod.setup_all_mappings, wk)
        if ok_m then
          logger.info("Mappings registered successfully.")
        else
          logger.error("Error in setup_all_mappings: " .. tostring(err_m))
        end
      else
        logger.error("Failed to load setup_all_mappings from keymaps.which-key.init: " .. tostring(map_mod))
      end

      logger.info("folke/which-key.nvim configuration complete.")
    end,
  },
}

