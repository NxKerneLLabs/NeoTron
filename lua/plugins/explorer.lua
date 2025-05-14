-- nvim/lua/plugins/explorer.lua
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "folke/which-key.nvim",
    },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeClose" },

    -- Load icons once with fallback
    opts = {
      hijack_cursor = true,
      hijack_netrw  = true,
      respect_buf_cwd   = true,
      sync_root_with_cwd = true,

      view = {
        width                       = 30,
        side                        = "left",
        preserve_window_proportions = true,
        signcolumn                  = "yes",
      },

      renderer = {
        root_folder_label = function(path)
          -- Use global logger
          local logger = require("core.debug.logger")("plugins.explorer.renderer")
          local icons = (pcall(require, "utils.icons") and require("utils.icons") or {})
          local folder_icon = icons.ui and icons.ui.FolderOpen or ""
          return folder_icon .. " " .. vim.fn.fnamemodify(path, ":t")
        end,

        highlight_git         = "all",
        highlight_diagnostics = "all",
        indent_markers        = { enable = true },
        icons = {
          show = { file = true, folder = true, folder_arrow = true, git = true, diagnostics = true },
          glyphs = {
            default = "", symlink = "",
            folder = {
              default     = "", open        = "",
              empty       = "", empty_open  = "",
              symlink     = "", symlink_open= "",
            },
            git = {
              unstaged  = "✗", staged   = "✓",
              unmerged  = "", renamed  = "➜",
              untracked = "★", deleted  = "🗑",
              ignored   = "◌",
            },
          },
        },
      },

      filters = {
        dotfiles = false,
        git      = { ignore = true },
        custom   = { "^.git$", "^node_modules$", "^%.cache$", "%.DS_Store" },
        exclude  = {},
      },

      git = { enable = true, ignore = false, timeout = 400 },

      diagnostics = {
        enable            = true,
        show_on_dirs      = true,
        show_on_open_dirs = true,
        icons = (function()
          local icons = (pcall(require, "utils.icons") and require("utils.icons") or {}).diagnostics or {}
          local function fb(val, def) return vim.g.icons_enabled and val or def end
          return {
            hint    = fb(icons.Hint,    "H"),
            info    = fb(icons.Info,    "I"),
            warning = fb(icons.Warn,    "W"),
            error   = fb(icons.Error,   "E"),
          }
        end)(),
      },

      update_focused_file = {
        enable        = true,
        update_root   = true,
        ignore_buftypes = { "nofile","prompt","help","quickfix","terminal","toggleterm","alpha","dashboard","floaterm" },
      },

      actions = {
        open_file = { quit_on_open = false, resize_window = true, window_picker = { enable = true, picker = "default" } },
        remove_file = { close_window = true },
      },
      trash       = { cmd = "trash" },
      live_filter = { prefix = "[FILTER]: ", always_show_folders = true },
      tab         = { sync = { open = true, close = true, ignore = {} } },
      notify      = { threshold = vim.log.levels.WARN },
    },

    config = function(_, opts)
      -- Centralized logger
      local get_logger = require("utils.logger")
      local logger     = get_logger("plugins.explorer.nvim-tree")

      logger.info("Configuring nvim-tree…")
      local ok, tree = pcall(require, "nvim-tree")
      if not ok then
        logger.error("Failed to load nvim-tree: " .. tostring(tree))
        return
      end
      tree.setup(opts)

      -- Visual setup & autocmds
      pcall(vim.api.nvim_set_hl, 0, "NvimTreeNormal", { bg = "#1e222a" })
      local function open_on_dir(data)
        if not (data and data.file and vim.fn.isdirectory(data.file) == 1) then return end
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
            if vim.api.nvim_buf_get_name(bufnr) ~= vim.fn.fnamemodify(data.file, ":p") then return end
          end
        end
        logger.info("Opening nvim-tree for directory: " .. data.file)
        local aok, api = pcall(require, "nvim-tree.api")
        if aok and api and api.tree then api.tree.open() else logger.error("API tree.open unavailable: "..tostring(api)) end
      end
      local grp = vim.api.nvim_create_augroup("NvimTreeOpenOnDir", { clear = true })
      vim.api.nvim_create_autocmd("VimEnter", { group = grp, pattern = "*", callback = open_on_dir, desc = "Open nvim-tree on dir" })

      -- Register keymaps
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok and wk.register then
        local eks_ok, eks = pcall(require, "keymaps.which-key.explorer")
        if eks_ok and eks.register then
          eks.register(wk, logger)
          logger.info("Explorer keymaps registered.")
        else
          logger.warn("Explorer which-key module missing or invalid: "..tostring(eks))
        end
      else
        logger.warn("which-key not available: "..tostring(wk))
      end

      logger.info("nvim-tree configured successfully.")
    end,
  },
}

