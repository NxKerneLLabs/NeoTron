-- nvim/lua/plugins/nvimtree.lua
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.nvimtree")) or fallback
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      -- "folke/which-key.nvim", -- Removido: which-key é gerido centralmente
    },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeClose" },
    opts = function() -- Convertido para função para carregar dependências no momento certo
      local icons_opts_ok, icons_opts_utils = pcall(require, "utils.icons")
      local tree_icons = {
        default_folder = "", open_folder = "", empty_folder = "", empty_open_folder = "",
        symlink_folder = "", symlink_open_folder = "",
        default_file = "", symlink_file = "",
        git_unstaged = "✗", git_staged = "✓", git_unmerged = "", git_renamed = "➜",
        git_untracked = "★", git_deleted = "🗑", git_ignored = "◌",
        diag_hint = "H", diag_info = "I", diag_warn = "W", diag_error = "E",
        root_folder = "",
      }

      if icons_opts_ok and icons_opts_utils then
        if icons_opts_utils.ui then
          tree_icons.default_folder = icons_opts_utils.ui.FolderClosed or tree_icons.default_folder
          tree_icons.open_folder = icons_opts_utils.ui.FolderOpen or tree_icons.open_folder
          tree_icons.root_folder = icons_opts_utils.ui.ProjectFolder or icons_opts_utils.ui.RootFolder or tree_icons.root_folder
          -- Adicione outros ícones de UI se necessário
        end
        if icons_opts_utils.git then
          tree_icons.git_unstaged = icons_opts_utils.git.Unstaged or icons_opts_utils.git.GitSignsDelete or tree_icons.git_unstaged
          tree_icons.git_staged = icons_opts_utils.git.Staged or icons_opts_utils.git.GitSignsAdd or tree_icons.git_staged
          -- Adicione outros ícones de git
        end
        if icons_opts_utils.diagnostics then
            tree_icons.diag_hint = icons_opts_utils.diagnostics.Hint or tree_icons.diag_hint
            tree_icons.diag_info = icons_opts_utils.diagnostics.Info or tree_icons.diag_info
            tree_icons.diag_warn = icons_opts_utils.diagnostics.Warn or tree_icons.diag_warn
            tree_icons.diag_error = icons_opts_utils.diagnostics.Error or tree_icons.diag_error
        end
      end

      return {
        hijack_cursor = true,
        hijack_netrw  = true,
        respect_buf_cwd = true,
        sync_root_with_cwd = true,
        view = {
          width = 30,
          side = "left",
          preserve_window_proportions = true,
          signcolumn = "yes",
        },
        renderer = {
          root_folder_label = function(path)
            return tree_icons.root_folder .. " " .. vim.fn.fnamemodify(path, ":t")
          end,
          highlight_git = "all",
          highlight_diagnostics = "all",
          indent_markers = { enable = true },
          icons = {
            show = { file = true, folder = true, folder_arrow = true, git = true, diagnostics = true },
            glyphs = {
              default = tree_icons.default_file,
              symlink = tree_icons.symlink_file,
              folder = {
                default = tree_icons.default_folder,
                open = tree_icons.open_folder,
                empty = tree_icons.empty_folder,
                empty_open = tree_icons.empty_open_folder,
                symlink = tree_icons.symlink_folder,
                symlink_open = tree_icons.symlink_open_folder,
              },
              git = {
                unstaged = tree_icons.git_unstaged,
                staged = tree_icons.git_staged,
                unmerged = tree_icons.git_unmerged,
                renamed = tree_icons.git_renamed,
                untracked = tree_icons.git_untracked,
                deleted = tree_icons.git_deleted,
                ignored = tree_icons.git_ignored,
              },
            },
          },
        },
        filters = {
          dotfiles = false,
          git = { ignore = true },
          custom = { "^.git$", "^node_modules$", "^%.cache$", "%.DS_Store" },
          exclude = {},
        },
        git = { enable = true, ignore = false, timeout = 400 },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
          icons = {
            hint = tree_icons.diag_hint,
            info = tree_icons.diag_info,
            warning = tree_icons.diag_warn,
            error = tree_icons.diag_error,
          },
        },
        update_focused_file = {
          enable = true,
          update_root = true,
          ignore_buftypes = { "nofile","prompt","help","quickfix","terminal","toggleterm","alpha","dashboard","floaterm" },
        },
        actions = {
          open_file = { quit_on_open = false, resize_window = true, window_picker = { enable = true, picker = "default" } },
          remove_file = { close_window = true },
        },
        trash = { cmd = "trash" },
        live_filter = { prefix = "[FILTER]: ", always_show_folders = true },
        tab = { sync = { open = true, close = true, ignore = {} } },
        notify = { threshold = vim.log.levels.WARN },
      }
    end,
    config = function(_, opts)
      local get_logger_fn -- Renomeado para evitar conflito com a variável logger
      local core_debug_setup_ok, core_debug_setup = pcall(require, "core.debug.logger")
      if core_debug_setup_ok and core_debug_setup and core_debug_setup.get_logger then
          get_logger_fn = core_debug_setup.get_logger
      else
          get_logger_fn = function(name) -- Fallback logger function
              return {
                  info  = function(m) print("INFO  [" .. name .. "_FB]: " .. m) end,
                  warn  = function(m) print("WARN  [" .. name .. "_FB]: " .. m) end,
                  error = function(m) print("ERROR [" .. name .. "_FB]: " .. m) end,
                  debug = function(m) print("DEBUG [" .. name .. "_FB]: " .. m) end,
              }
          end
          if not core_debug_setup_ok then
            print("ERROR [NvimTree_Config_FB]: core.debug.logger module not found. Error: " .. tostring(core_debug_setup))
          elseif not (core_debug_setup and core_debug_setup.get_logger) then
            print("ERROR [NvimTree_Config_FB]: core.debug.logger.get_logger function not found.")
          end
      end
      local nvim_tree_logger = get_logger_fn("plugins.explorer.nvim-tree") -- Uso da variável renomeada

      nvim_tree_logger.info("Configuring nvim-tree…")
      local ok, tree = pcall(require, "nvim-tree")
      if not ok then
        nvim_tree_logger.error("Failed to load nvim-tree: " .. tostring(tree))
        return
      end
      tree.setup(opts)

      pcall(vim.api.nvim_set_hl, 0, "NvimTreeNormal", { bg = "#1e222a" })
      local function open_on_dir(data)
        if not (data and data.file and vim.fn.isdirectory(data.file) == 1) then return end
        for _, bufnr_iter in ipairs(vim.api.nvim_list_bufs()) do -- Renomeado bufnr para evitar shadowing
          if vim.api.nvim_buf_is_loaded(bufnr_iter) and vim.bo[bufnr_iter].buftype == "" then
            if vim.api.nvim_buf_get_name(bufnr_iter) ~= vim.fn.fnamemodify(data.file, ":p") then return end
          end
        end
        nvim_tree_logger.info("Opening nvim-tree for directory: " .. data.file)
        local aok, api = pcall(require, "nvim-tree.api")
        if aok and api and api.tree and api.tree.open then -- Verificação mais robusta
            api.tree.open()
        else
            nvim_tree_logger.error("API tree.open unavailable. API loaded: " .. tostring(aok) .. ", API object: " .. vim.inspect(api))
        end
      end
      local grp = vim.api.nvim_create_augroup("NvimTreeOpenOnDir", { clear = true })
      vim.api.nvim_create_autocmd("VimEnter", { group = grp, pattern = "*", callback = open_on_dir, desc = "Open nvim-tree on dir" })

      -- REMOVIDO: Bloco de registo de keymaps do NvimTree com which-key.
      -- Esta responsabilidade foi movida para o orquestrador de keymaps (lua/keymaps/init.lua)
      -- e para o ficheiro de definição (lua/keymaps/definitions/nvimtree.lua).
      -- nvim_tree_logger.info("NvimTree keymap registration with which-key will be handled by the central keymap orchestrator.")

      nvim_tree_logger.info("nvim-tree configured successfully.")
    end,
  },
}

