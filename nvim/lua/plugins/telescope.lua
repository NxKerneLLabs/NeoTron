-- nvim/lua/plugins/telescope.lua
-- Plugin specifications for Telescope, project management, and code navigation.
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "ahmedkhalf/project.nvim",
    },
 
      -- Actions and layout
      local actions = (pcall(require, "telescope.actions") and require("telescope.actions")) or nil
      local actions_layout = (pcall(require, "telescope.actions.layout") and require("telescope.actions.layout")) or nil
      if not actions or not actions_layout then
        logger.warn("Some telescope actions modules failed to load.")
      end

      -- Icons
      local ui_icons = (pcall(require, "utils.icons") and require("utils.icons").ui) or {}
      local icons = {
        prompt    = (ui_icons.Telescope or ui_icons.Search or "") .. " ",
        selection = (ui_icons.ChevronRight or "") .. " ",
        multi     = (ui_icons.BoldClose or "") .. " ",
      }
      -- Custom actions
      local custom = {}
      do
        local ok_mt, mt = pcall(require, "telescope.actions.mt")
        if ok_mt and mt then
          custom = mt.transform_mod({
            open_in_vscode = function(bufnr)
              local sel = require("telescope.actions.state").get_selected_entry()
              if not sel then return logger.warn("No selection for VSCode") end
              local path = sel.filename or sel.value
              if actions then actions.close(bufnr) end
              vim.fn.system({ "code", "--goto", path })
              logger.info("Opened in VSCode: "..path)
            end,
            open_in_tabs = function(bufnr)
              if not actions then return logger.warn("Actions missing for tabs") end
              local picker = require("telescope.actions.state").get_current_picker(bufnr)
              local sel = picker:get_multi_selection()
              actions.close(bufnr)
              for _, e in ipairs(sel) do
                local p = e.value or e.filename
                if p then vim.cmd("tabedit "..vim.fn.fnameescape(p)) end
              end
              logger.info("Opened "..#sel.." in tabs.")
            end,
          })
        else
          logger.warn("telescope.actions.mt not available: "..tostring(mt))
        end
return {
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🔭 Telescope — Fuzzy Finder                              │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope", -- Lazy-load on the Telescope command
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required dependency
      {
        "nvim-telescope/telescope-fzf-native.nvim", -- Optional: FZF sorter for performance
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end, -- Only build if make is available
      },
      "nvim-telescope/telescope-ui-select.nvim", -- For using Telescope as vim.ui.select
      "nvim-telescope/telescope-file-browser.nvim", -- Se usares as suas funcionalidades de browser de ficheiros
      "ahmedkhalf/project.nvim", -- Para gestão de projetos e pickers de projeto no Telescope
      -- "folke/which-key.nvim", -- Já não é uma dependência direta aqui para registo de keymaps
    },
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.telescope")
      else
        logger = { info = function(m) print("INFO [TeleP_FB]: " .. m) end, error = function(m) print("ERROR [TeleP_FB]: " .. m) end, warn = function(m) print("WARN [TeleP_FB]: " .. m) end, debug = function(m) print("DEBUG [TeleP_FB]: " .. m) end }
        logger.error("core.debug.get_logger not found. Using fallback for Telescope config.")
      end

      logger.info("Configuring nvim-telescope/telescope.nvim...")

      local telescope_ok, telescope = pcall(require, "telescope")
      if not telescope_ok then
        logger.error("Failed to load 'telescope' module. Setup aborted. Error: " .. tostring(telescope))
        return
      end

      local actions_ok, actions = pcall(require, "telescope.actions")
      local action_layout_ok, actions_layout = pcall(require, "telescope.actions.layout")

      if not (actions_ok and action_layout_ok) then
        logger.error("Failed to load Telescope actions or layout modules. Setup might be incomplete. Actions Error: " .. tostring(actions) .. ", Layout Error: " .. tostring(actions_layout))
      end

      local icons_ok, icons_utils = pcall(require, "utils.icons")
      local telescope_icons = { prompt = " ", selection = " ", multi = " " }
      if icons_ok and icons_utils and icons_utils.ui then
        telescope_icons.prompt = (icons_utils.ui.Telescope or icons_utils.ui.Search or "") .. " "
        telescope_icons.selection = (icons_utils.ui.Forward or icons_utils.ui.ChevronRight or "") .. " "
        telescope_icons.multi = (icons_utils.ui.BoldClose or "") .. " "
      else
        logger.warn("utils.icons.ui not found for Telescope config. Using default text icons. Error: " .. tostring(icons_utils))
      end

      local custom_telescope_actions = {}
      local transform_mod_ok, transform_mod = pcall(require, "telescope.actions.mt")
      if transform_mod_ok and transform_mod then
        custom_telescope_actions = transform_mod.transform_mod({
          open_in_vscode = function(prompt_bufnr)
            local selection = require("telescope.actions.state").get_selected_entry()
            if not selection then return logger.warn("Telescope: No selection to open in VSCode.") end
            local filepath = selection.filename or selection.path or selection.value
            if not filepath then return logger.warn("Telescope: No filepath in selection for VSCode.") end
            local cmd_str = string.format("code --goto \"%s\"", filepath) -- Ensure path is quoted
            if actions then actions.close(prompt_bufnr) end
            vim.fn.system(cmd_str)
            logger.info("Telescope: Attempted to open '" .. filepath .. "' in VSCode.")
          end,
          open_in_tabs = function(prompt_bufnr)
            if not actions then logger.error("Telescope actions module not loaded for open_in_tabs."); return end
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            local multi = picker:get_multi_selection()
            if #multi > 0 then
              actions.close(prompt_bufnr)
              for _, entry in ipairs(multi) do
                local path_to_open = entry.value or entry.filename or entry.path
                if path_to_open then vim.cmd("tabedit " .. vim.fn.fnameescape(path_to_open)) end
              end
              logger.info("Telescope: Opened " .. #multi .. " selections in new tabs.")
            else
              actions.select_tab(prompt_bufnr)
              logger.info("Telescope: Opened current selection in a new tab.")
            end
          end,
        })
      else
        logger.warn("telescope.actions.mt (transform_mod) not found. Custom Telescope actions may not work. Error: " .. tostring(transform_mod))

      end

      telescope.setup({
        defaults = {

          prompt_prefix    = icons.prompt,
          selection_caret  = icons.selection,
          multi_icon       = icons.multi,
          sorting_strategy = "ascending",
          layout_strategy  = "horizontal",
          layout_config    = { horizontal = { prompt_position = "top", preview_width = 0.55, results_width = 0.8 }, width = 0.87, height = 0.80 },
          file_ignore_patterns = {"node_modules","%.git/","dist/"},
          mappings = {
            i = {
              ["<C-c>"] = actions and actions.close,
              ["<esc>"] = actions and actions.close,
              ["<C-j>"] = actions and actions.move_selection_next,
              ["<C-k>"] = actions and actions.move_selection_previous,
              ["<C-q>"] = actions and function(b) actions.smart_send_to_qflist(b); actions.open_qflist(b) end,
              ["<C-t>"] = custom.open_in_tabs,
              ["<C-p>"] = actions_layout and actions_layout.toggle_preview,
            },
            n = {
              ["q"]    = actions and actions.close,
              ["<C-t>"] = custom.open_in_tabs,
              ["<C-p>"] = actions_layout and actions_layout.toggle_preview,

          prompt_prefix = telescope_icons.prompt,
          selection_caret = telescope_icons.selection,
          multi_icon = telescope_icons.multi,
          path_display = { "smart" },
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55, results_width = 0.8 },
            vertical = { mirror = false },
            width = 0.87, height = 0.80, preview_cutoff = 120,
          },
          file_ignore_patterns = { "node_modules", "%.git/", "dist/", "%.lock", "%.o", "%.obj", "%.DS_Store", "%.svg", "%.webp", "%.png", "%.jpeg", "%.jpg", "%.gif" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" },
          selection_strategy = "reset",
          mappings = {
            i = {
              ["<C-c>"] = actions and actions.close or function() logger.warn("Actions not loaded for close") end,
              ["<esc>"] = actions and actions.close or function() logger.warn("Actions not loaded for close") end,
              ["<C-j>"] = actions and actions.move_selection_next or function() logger.warn("Actions not loaded for move_selection_next") end,
              ["<C-k>"] = actions and actions.move_selection_previous or function() logger.warn("Actions not loaded for move_selection_previous") end,
              ["<C-q>"] = actions and function(prompt_bufnr) actions.smart_send_to_qflist(prompt_bufnr); actions.open_qflist(prompt_bufnr) end or function() logger.warn("Actions not loaded for qflist") end,
              ["<C-s>"] = actions and actions.select_horizontal or function() logger.warn("Actions not loaded for select_horizontal") end,
              ["<C-v>"] = actions and actions.select_vertical or function() logger.warn("Actions not loaded for select_vertical") end,
              ["<C-t>"] = custom_telescope_actions.open_in_tabs or function() logger.warn("Custom action open_in_tabs not loaded.") end,
              ["<C-u>"] = actions and actions.preview_scrolling_up or function() logger.warn("Actions not loaded for preview_scrolling_up") end,
              ["<C-d>"] = actions and actions.preview_scrolling_down or function() logger.warn("Actions not loaded for preview_scrolling_down") end,
              ["<C-p>"] = action_layout_ok and actions_layout.toggle_preview or function() logger.warn("Action layout not loaded for toggle_preview") end,
              ["<C-/>"] = actions and actions.which_key or function() logger.warn("Actions not loaded for which_key") end,
            },
            n = {
              ["q"] = actions and actions.close or function() logger.warn("Actions not loaded for close") end,
              ["<esc>"] = actions and actions.close or function() logger.warn("Actions not loaded for close") end,
              ["<C-j>"] = actions and actions.move_selection_next or function() logger.warn("Actions not loaded for move_selection_next") end,
              ["<C-k>"] = actions and actions.move_selection_previous or function() logger.warn("Actions not loaded for move_selection_previous") end,
              ["<C-q>"] = actions and function(prompt_bufnr) actions.smart_send_to_qflist(prompt_bufnr); actions.open_qflist(prompt_bufnr) end or function() logger.warn("Actions not loaded for qflist") end,
              ["<C-t>"] = custom_telescope_actions.open_in_tabs or function() logger.warn("Custom action open_in_tabs not loaded.") end,
              ["<C-p>"] = action_layout_ok and actions_layout.toggle_preview or function() logger.warn("Action layout not loaded for toggle_preview") end,
              ["?"] = actions and actions.which_key or function() logger.warn("Actions not loaded for which_key") end,

            },
          },
        },
        pickers = {

          find_files = { hidden = true },
          live_grep  = { additional_args = function() return {"--hidden"} end },
        },
        extensions = {
          ["fzf"] = { fuzzy = true, override_generic_sorter = true },
          ["ui-select"] = (pcall(require, "telescope.themes") and require("telescope.themes").get_dropdown()) or {},
        },
      })
      logger.success("telescope.setup() completed.")

      -- Safely load extensions (use 'project' instead of 'project_nvim')
      for _, ext in ipairs({"fzf","ui-select","projects"}) do
        local ok_ext, err = pcall(telescope.load_extension, ext)
        if ok_ext then
          logger.success("Loaded extension: "..ext)
        else
          logger.warn("Could not load extension '"..ext.."': "..tostring(err))
        end
      end

      logger.info("telescope.nvim configured successfully.")

          find_files = {
            hidden = true,
            previewer = true,
            find_command = { "rg", "--files", "--hidden", "--no-ignore-vcs", "-g", "!{.git,node_modules,dist,target,build}/" },
          },
          live_grep = {
            additional_args = function() return { "--hidden", "--no-ignore-vcs", "-g", "!{.git,node_modules,dist,target,build}/" } end,
          },
          buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            mappings = {
              i = { ["<c-d>"] = actions and actions.delete_buffer or function() logger.warn("Actions not loaded for delete_buffer") end },
              n = { ["dd"] = actions and actions.delete_buffer or function() logger.warn("Actions not loaded for delete_buffer") end },
            },
          },
          git_files = { show_untracked = true },
        },
        extensions = {
          fzf = {
            fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case",
          },
          ["ui-select"] = (pcall(require, "telescope.themes") and require("telescope.themes").get_dropdown({})) or {},
          -- A configuração da extensão "project_nvim" (de ahmedkhalf/project.nvim) é feita
          -- pelo próprio plugin project.nvim quando ele se regista no Telescope.
          -- Não é necessário configurar "project_nvim" aqui dentro de extensions,
          -- apenas garantir que é carregado abaixo com telescope.load_extension("project_nvim").
        },
      })
      logger.debug("telescope.setup() completed.")

      -- Load enabled extensions
      -- Alterado "project" para "project_nvim"
      local extensions_to_load = { "fzf", "ui-select", "projects_nvim" } -- "file_browser"
      for _, ext_name in ipairs(extensions_to_load) do
        local load_ok, load_err = pcall(telescope.load_extension, ext_name)
        if load_ok then
          logger.debug("Telescope extension '" .. ext_name .. "' loaded.")
        else
          logger.warn("Failed to load Telescope extension '" .. ext_name .. "'. It might not be installed or has issues. Error: " .. tostring(load_err))
        end
      end

      -- REMOVIDO: Bloco de registo de keymaps do Telescope com which-key.
      -- Esta responsabilidade foi movida para o orquestrador de keymaps (lua/keymaps/init.lua)
      -- e para o ficheiro de definição (lua/keymaps/definitions/telescope.lua).
      -- logger.info("Telescope keymap registration with which-key will be handled by the central keymap orchestrator.")

      logger.info("nvim-telescope/telescope.nvim configured successfully.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │  Project Management (project.nvim)                      │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      local logger_proj
      -- Corrigido: Usar core.debug.logger consistentemente
      local core_debug_ok_proj, core_debug_proj = pcall(require, "core.debug.logger")
      if core_debug_ok_proj and core_debug_proj and core_debug_proj.get_logger then
        logger_proj = core_debug_proj.get_logger("plugins.project")
      else
        logger_proj = { info = function(m) print("INFO [ProjP_FB]: " .. m) end, error = function(m) print("ERROR [ProjP_FB]: " .. m) end, warn = function(m) print("WARN [ProjP_FB]: " .. m) end, debug = function(m) print("DEBUG [ProjP_FB]: " .. m) end }
        logger_proj.error("core.debug.logger not found for project.nvim config.")
      end

      logger_proj.info("Configuring ahmedkhalf/project.nvim...")
      local project_ok, project = pcall(require, "project_nvim")
      if not project_ok then
        logger_proj.error("Failed to load 'project_nvim' module. Project.nvim setup aborted. Error: " .. tostring(project))
        return
      end

      project.setup({
        manual_mode = false,
        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml", "setup.py", "pyproject.toml", "go.mod" },
        ignore_lsp = {},
        exclude_dirs = { vim.fn.stdpath("config") },
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = "global",
        datapath = vim.fn.stdpath("data") .. "/project_nvim",
      })
      logger_proj.info("project.nvim configured.")

      -- Opcional: Carregar a extensão do Telescope aqui se não foi feito acima,
      -- ou se project.nvim precisar ser configurado antes que o Telescope tente carregar sua extensão.
      -- No entanto, a abordagem de carregar em `telescope.config` é geralmente preferida se
      -- `project.nvim` já estiver disponível como dependência.
      -- Se houver problemas de timing, pode ser necessário garantir que `project.nvim`
      -- complete o seu setup e registe a sua extensão ANTES que `telescope.load_extension("project_nvim")` seja chamado.
      -- Uma forma de garantir isso é se o Telescope tiver `project.nvim` como `dependencies` e
      -- `project.nvim` for configurado com `lazy = false` ou um evento que dispare antes do Telescope.
      -- Mas, na maioria dos casos, a ordem atual com `project.nvim` como dependência do Telescope deve funcionar.
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🍞 Code Context (nvim-navic)                             │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig", "nvim-tree/nvim-web-devicons" },
    lazy = true,
    init = function()
      vim.g.navic_silence = true
    end,
    config = function()
      local logger_navic
      -- Corrigido: Usar core.debug.logger consistentemente
      local core_debug_ok_navic, core_debug_navic = pcall(require, "core.debug.logger")
      if core_debug_ok_navic and core_debug_navic and core_debug_navic.get_logger then
        logger_navic = core_debug_navic.get_logger("plugins.navic")
      else
        logger_navic = { info = function(m) print("INFO [NavicP_FB]: " .. m) end, error = function(m) print("ERROR [NavicP_FB]: " .. m) end, warn = function(m) print("WARN [NavicP_FB]: " .. m) end, debug = function(m) print("DEBUG [NavicP_FB]: " .. m) end }
        logger_navic.error("core.debug.logger not found for nvim-navic config.")
      end

      logger_navic.info("Configuring SmiteshP/nvim-navic...")
      local navic_ok, navic = pcall(require, "nvim-navic")
      if not navic_ok then
        logger_navic.error("Failed to load 'nvim-navic' module. Nvim-Navic setup aborted. Error: " .. tostring(navic))
        return
      end

      local icons_ok_navic, icons_navic_utils = pcall(require, "utils.icons")
      local navic_icons = {}
      if icons_ok_navic and icons_navic_utils and icons_navic_utils.kinds then
        navic_icons = icons_navic_utils.kinds
        logger_navic.debug("Custom icons for nvim-navic loaded from utils.icons.kinds.")
      else
        logger_navic.warn("utils.icons.kinds not found for nvim-navic config. Using default icons. Error: " .. tostring(icons_navic_utils))
      end

      navic.setup({
        icons = navic_icons,
        highlight = true,
        separator = " > ",
        depth_limit = 5,
        depth_limit_indicator = "..",
        lsp = {
          auto_attach = true,
          preference = nil,
        }
      })
      logger_navic.info("nvim-navic configured.")
    end,
  },
}
