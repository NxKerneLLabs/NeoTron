-- nvim/lua/plugins/navigation.lua
-- Plugin specifications for Telescope, project management, and code navigation.

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
      "nvim-telescope/telescope-file-browser.nvim", -- If you use its file browser features
      "ahmedkhalf/project.nvim", -- For project-specific Telescope searches (e.g., project files)
      "folke/which-key.nvim",  -- For registering Telescope keymaps
    },
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug")
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
      -- local themes_ok, themes = pcall(require, "telescope.themes") -- themes.get_dropdown() is used below

      if not (actions_ok and action_layout_ok) then
        logger.error("Failed to load Telescope actions or layout modules. Setup might be incomplete. Actions Error: " .. tostring(actions) .. ", Layout Error: " .. tostring(actions_layout))
        -- Continue if telescope main module loaded, but warn.
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

      -- Custom actions (open_in_vscode, open_in_tabs)
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
              actions.select_tab(prompt_bufnr) -- select_default will open in current window, select_tab in new tab
              logger.info("Telescope: Opened current selection in a new tab.")
            end
          end,
        })
      else
        logger.warn("telescope.actions.mt (transform_mod) not found. Custom Telescope actions (e.g., open_in_vscode) may not work. Error: " .. tostring(transform_mod))
      end

      telescope.setup({
        defaults = {
          prompt_prefix = telescope_icons.prompt,
          selection_caret = telescope_icons.selection,
          multi_icon = telescope_icons.multi,
          path_display = { "smart" }, -- "truncate", "absolute", "relative", "smart"
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55, results_width = 0.8 },
            vertical = { mirror = false },
            width = 0.87, height = 0.80, preview_cutoff = 120,
          },
          file_ignore_patterns = { "node_modules", "%.git/", "dist/", "%.lock", "%.o", "%.obj", "%.DS_Store", "%.svg", "%.webp", "%.png", "%.jpeg", "%.jpg", "%.gif" },
          winblend = 0,
          border = {}, -- Use theme's default border
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }, -- Fallback if theme doesn't provide
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" },
          selection_strategy = "reset", -- "reset", "follow", "row"
          mappings = {
            i = {
              ["<C-c>"] = actions and actions.close or function() logger.warn("Actions not loaded for close") end,
              ["<esc>"] = actions and actions.close or function() logger.warn("Actions not loaded for close") end,
              ["<C-j>"] = actions and actions.move_selection_next or function() logger.warn("Actions not loaded for move_selection_next") end,
              ["<C-k>"] = actions and actions.move_selection_previous or function() logger.warn("Actions not loaded for move_selection_previous") end,
              ["<C-q>"] = actions and function() actions.smart_send_to_qflist(prompt_bufnr); actions.open_qflist(prompt_bufnr) end or function() logger.warn("Actions not loaded for qflist") end,
              ["<C-s>"] = actions and actions.select_horizontal or function() logger.warn("Actions not loaded for select_horizontal") end,
              ["<C-v>"] = actions and actions.select_vertical or function() logger.warn("Actions not loaded for select_vertical") end,
              ["<C-t>"] = custom_telescope_actions.open_in_tabs or function() logger.warn("Custom action open_in_tabs not loaded.") end,
              ["<C-u>"] = actions and actions.preview_scrolling_up or function() logger.warn("Actions not loaded for preview_scrolling_up") end,
              ["<C-d>"] = actions and actions.preview_scrolling_down or function() logger.warn("Actions not loaded for preview_scrolling_down") end,
              ["<C-p>"] = action_layout_ok and actions_layout.toggle_preview or function() logger.warn("Action layout not loaded for toggle_preview") end,
              ["<C-/>"] = actions and actions.which_key or function() logger.warn("Actions not loaded for which_key") end,
              -- ["<C-w>"] = function() vim.api.nvim_input("<c-s-w>") end, -- This seems like a custom mapping, ensure it's intended
            },
            n = { -- Normal mode mappings for Telescope window
              ["q"] = actions and actions.close or function() logger.warn("Actions not loaded for close") end,
              ["<esc>"] = actions and actions.close or function() logger.warn("Actions not loaded for close") end,
              ["<C-j>"] = actions and actions.move_selection_next or function() logger.warn("Actions not loaded for move_selection_next") end,
              ["<C-k>"] = actions and actions.move_selection_previous or function() logger.warn("Actions not loaded for move_selection_previous") end,
              ["<C-q>"] = actions and function() actions.smart_send_to_qflist(prompt_bufnr); actions.open_qflist(prompt_bufnr) end or function() logger.warn("Actions not loaded for qflist") end,
              ["<C-t>"] = custom_telescope_actions.open_in_tabs or function() logger.warn("Custom action open_in_tabs not loaded.") end,
              ["<C-p>"] = action_layout_ok and actions_layout.toggle_preview or function() logger.warn("Action layout not loaded for toggle_preview") end,
              ["?"] = actions and actions.which_key or function() logger.warn("Actions not loaded for which_key") end,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            previewer = true,
            find_command = { "rg", "--files", "--hidden", "--no-ignore-vcs", "-g", "!{.git,node_modules,dist,target,build}/" },
            -- For systems without rg, you might need a fallback or ensure rg is a dependency.
            -- theme = "dropdown", -- Example: use a specific theme for this picker
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
          -- Configure other pickers as needed
        },
        extensions = {
          fzf = {
            fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case",
          },
          ["ui-select"] = (pcall(require, "telescope.themes") and require("telescope.themes").get_dropdown({})) or {},
          -- file_browser = { hijack_netrw = true, path = "%:p:h", grouped = true },
          project = {
            base_dirs = {
              "~/projects", -- Add your project directories
              "~/workspace",
            },
            hidden_files = true,
            sync_with_nvim_tree = true, -- If you use nvim-tree
          }
        },
      })
      logger.debug("telescope.setup() completed.")

      -- Load enabled extensions
      local extensions_to_load = { "fzf", "ui-select", "project" } -- "file_browser"
      for _, ext_name in ipairs(extensions_to_load) do
        local load_ok, load_err = pcall(telescope.load_extension, ext_name)
        if load_ok then
          logger.debug("Telescope extension '" .. ext_name .. "' loaded.")
        else
          logger.warn("Failed to load Telescope extension '" .. ext_name .. "'. It might not be installed or has issues. Error: " .. tostring(load_err))
        end
      end

      -- Register Telescope keymaps with which-key
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok and wk then
        local telescope_keymaps_module_ok, telescope_keymaps_module = pcall(require, "keymaps.which-key.telescope")
        if telescope_keymaps_module_ok and telescope_keymaps_module and type(telescope_keymaps_module.register) == "function" then
          local keymap_logger = (core_debug_ok and core_debug.get_logger) and core_debug.get_logger("keymaps.which-key.telescope") or logger
          telescope_keymaps_module.register(wk, keymap_logger) -- Pass logger
          logger.info("Telescope keymaps successfully registered with which-key.")
        else
          logger.warn("Failed to load or register Telescope keymaps from 'keymaps.which-key.telescope'. Error or module structure issue: " .. tostring(telescope_keymaps_module))
        end
      else
        logger.warn("'which-key' module not available when configuring Telescope. Keymaps skipped. Error: " .. tostring(wk))
      end
      logger.info("nvim-telescope/telescope.nvim configured successfully.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │  Project Management (project.nvim)                      │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy", -- Or load on specific events like "BufWinEnter"
    -- cmd = "ProjectRoot", -- Example command if you want to trigger loading
    config = function()
      local logger_proj
      local core_debug_ok_proj, core_debug_proj = pcall(require, "core.debug")
      if core_debug_ok_proj and core_debug_proj and core_debug_proj.get_logger then
        logger_proj = core_debug_proj.get_logger("plugins.project")
      else
        logger_proj = { info = function(m) print("INFO [ProjP_FB]: " .. m) end, error = function(m) print("ERROR [ProjP_FB]: " .. m) end, warn = function(m) print("WARN [ProjP_FB]: " .. m) end }
        logger_proj.error("core.debug.get_logger not found for project.nvim config.")
      end

      logger_proj.info("Configuring ahmedkhalf/project.nvim...")
      local project_ok, project = pcall(require, "project_nvim")
      if not project_ok then
        logger_proj.error("Failed to load 'project_nvim' module. Project.nvim setup aborted. Error: " .. tostring(project))
        return
      end

      project.setup({
        manual_mode = false, -- true if you want to manually manage projects
        detection_methods = { "lsp", "pattern" }, -- "lsp" uses LSP root_dir, "pattern" looks for files/dirs
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml", "setup.py", "pyproject.toml", "go.mod" },
        ignore_lsp = {}, -- List of LSPs to ignore for project detection
        exclude_dirs = { vim.fn.stdpath("config") }, -- Don't treat nvim config as a project
        show_hidden = false, -- Show hidden projects in Telescope picker
        silent_chdir = true, -- Change directory without messages
        scope_chdir = "global", -- "global", "tab", "win"
        datapath = vim.fn.stdpath("data") .. "/project_nvim", -- Where project data is stored
      })
      logger_proj.info("project.nvim configured.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🍞 Code Context (nvim-navic)                             │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig", "nvim-tree/nvim-web-devicons" },
    lazy = true, -- Can be loaded when LspAttach event happens
    init = function()
      vim.g.navic_silence = true -- Suppress nvim-navic's own messages if desired
      -- You can set global options for nvim-navic here if needed before its setup
    end,
    config = function()
      local logger_navic
      local core_debug_ok_navic, core_debug_navic = pcall(require, "core.debug")
      if core_debug_ok_navic and core_debug_navic and core_debug_navic.get_logger then
        logger_navic = core_debug_navic.get_logger("plugins.navic")
      else
        logger_navic = { info = function(m) print("INFO [NavicP_FB]: " .. m) end, error = function(m) print("ERROR [NavicP_FB]: " .. m) end, warn = function(m) print("WARN [NavicP_FB]: " .. m) end }
        logger_navic.error("core.debug.get_logger not found for nvim-navic config.")
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
        icons = navic_icons, -- Uses icons from your utils.icons.kinds table
        highlight = true,    -- Highlight the current symbol in navic
        separator = " > ",
        depth_limit = 5,
        depth_limit_indicator = "..",
        lsp = {
            auto_attach = true, -- Automatically attach to LSP clients
            preference = nil,   -- Order of LSP clients to prefer for symbols
        }
      })
      logger_navic.info("nvim-navic configured.")
      -- Note: nvim-navic is typically attached to LSP clients in the on_attach function
      -- of your nvim-lspconfig setup (as seen in your plugins/lsp.lua).
      -- This config function here sets up navic's global options.
    end,
  },
}

