-- lua/plugins/neo-tree.lua
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.neo-tree")) or fallback
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local logger = require("core.debug.logger").get_logger("neo-tree")
      local icons = require("utils.icons") or {}

      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        sources = { "filesystem", "buffers", "git_status", "diagnostics" },

        -- Janela
        window = {
          position = "float", -- Janela flutuante pra estilo
          width = 40,
          height = 20,
          mapping_options = { noremap = true, nowait = true },
          mappings = {
            ["<space>"] = "toggle_node",
            ["<cr>"] = "open",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["a"] = { "add", config = { show_path = "relative" } },
            ["A"] = "add_directory",
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy",
            ["m"] = "move",
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
            ["f"] = "telescope_find", -- Integração com Telescope
          },
        },

        -- Filesystem
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = true,
          },
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },

        -- Buffers
        buffers = {
          follow_current_file = { enabled = true },
          group_empty_dirs = true,
        },

        -- Git Status
        git_status = {
          window = { position = "float" },
        },

        -- Comandos personalizados
        commands = {
          telescope_find = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" then
              require("telescope.builtin").find_files({ cwd = node:get_id() })
            else
              require("telescope.builtin").find_files({ cwd = node.extra.cwd })
            end
            logger.info("Telescope opened from Neo Tree: " .. node:get_id())
          end,
        },

        -- Ícones
        default_component_configs = {
          icon = {
            folder_closed = icons.ui and icons.ui.Folder or "📁",
            folder_open = icons.ui and icons.ui.FolderOpen or "📂",
            folder_empty = icons.ui and icons.ui.FolderEmpty or "🗀",
          },
          git_status = {
            symbols = {
              added = icons.git and icons.git.Add or "✚",
              modified = icons.git and icons.git.Mod or "✹",
              deleted = icons.git and icons.git.Remove or "✖",
            },
          },
        },
      })

      logger.info("Neo Tree configurado com sucesso!")
    end,
  },
}
