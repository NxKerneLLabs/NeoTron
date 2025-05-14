-- nvim/lua/plugins/git.lua
-- Plugin specifications for Git integration: gitsigns, diffview, fugitive, and templ (GitLab CI).

return {
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 📊 Gitsigns (Git decorations in the signcolumn)          │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- Load early for signs and blame
    dependencies = { "folke/which-key.nvim" }, -- For registering which-key mappings if needed
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.gitsigns")
      else
        logger = { info = function(m) print("INFO [GitSignsP_FB]: " .. m) end, error = function(m) print("ERROR [GitSignsP_FB]: " .. m) end, warn = function(m) print("WARN [GitSignsP_FB]: " .. m) end, debug = function(m) print("DEBUG [GitSignsP_FB]: " .. m) end }
        logger.error("core.debug.get_logger not found. Using fallback for gitsigns config.")
      end

      logger.info("Configuring lewis6991/gitsigns.nvim...")

      local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
      if not gitsigns_ok then
        logger.error("Failed to load 'gitsigns' module. Setup aborted. Error: " .. tostring(gitsigns))
        return
      end

      local icons_ok, icons_utils = pcall(require, "utils.icons")
      local signs = {
        add = { text = "▎" }, change = { text = "▎" }, delete = { text = "▎" },
        topdelete = { text = "▎" }, changedelete = { text = "▎" }, untracked = { text = "▎" },
      }
      if icons_ok and icons_utils and icons_utils.git then
        signs.add          = { text = icons_utils.git.GitSignsAdd or "▎A" }
        signs.change       = { text = icons_utils.git.GitSignsChange or "▎M" }
        signs.delete       = { text = icons_utils.git.GitSignsDelete or "▎D" }
        signs.topdelete    = { text = icons_utils.git.GitSignsTopDelete or "▎TD" }
        signs.changedelete = { text = icons_utils.git.GitSignsChangeDelete or "▎CD" }
        signs.untracked    = { text = icons_utils.git.Untracked or "▎U" }
        logger.debug("Using custom icons for gitsigns.")
      else
        logger.warn("utils.icons.git not found for gitsigns. Using default text signs. Error: " .. tostring(icons_utils))
      end

      gitsigns.setup({
        signs = signs,
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = { interval = 1000, follow_files = true },
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = true,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000,
        preview_config = {
          border = "rounded", style = "minimal", relative = "cursor", row = 0, col = 1,
        },
        on_attach = function(bufnr)
          logger.debug("gitsigns attached to buffer: " .. bufnr)
          local gs = package.loaded.gitsigns -- Use the already loaded module

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            opts.silent = true
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function() if vim.wo.diff then return "]c" end; vim.schedule(gs.next_hunk); return "<Ignore>" end, { expr = true, desc = "Next Git Hunk" })
          map("n", "[c", function() if vim.wo.diff then return "[c" end; vim.schedule(gs.prev_hunk); return "<Ignore>" end, { expr = true, desc = "Previous Git Hunk" })

          -- Actions (These are buffer-local, which-key will show global <leader>g mappings)
          -- The <leader>gs, <leader>gr etc. mappings are defined in keymaps/which-key/git.lua
          -- and call functions from functions/git.lua, which in turn call gs.stage_hunk etc.
          -- So, no need to redefine them here for which-key visibility.
          -- However, these on_attach mappings are good for direct interaction without which-key.
          map("n", "<leader>hs", gs.stage_hunk, { desc = "Git: Stage Hunk" })             -- Example: <leader>hs for stage hunk (buffer local)
          map("n", "<leader>hr", gs.reset_hunk, { desc = "Git: Reset Hunk" })             -- Example: <leader>hr for reset hunk
          map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Git: Stage Selected Hunks" })
          map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Git: Reset Selected Hunks" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "Git: Stage Buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Git: Undo Stage Hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "Git: Reset Buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Git: Preview Hunk" })
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Git: Blame Line" })
          map("n", "<leader>hB", gs.toggle_current_line_blame, { desc = "Git: Toggle Line Blame" })
          map("n", "<leader>hd", function() gs.diffthis("~") end, { desc = "Git: Diff This ~" }) -- Diff vs HEAD~
          map("n", "<leader>hD", function() gs.diffthis("@") end, { desc = "Git: Diff This @" }) -- Diff vs Index (Staged)


          -- Text Object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Git: Select Hunk (Text Object)" })
        end,
      })
      logger.info("gitsigns.nvim configured.")

      -- Explicitly register which-key git mappings after gitsigns is set up
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok and wk then
        local git_keymaps_module_ok, git_keymaps_module = pcall(require, "keymaps.which-key.git")
        if git_keymaps_module_ok and git_keymaps_module and type(git_keymaps_module.register) == "function" then
          local keymap_logger = (core_debug_ok and core_debug.get_logger) and core_debug.get_logger("keymaps.which-key.git") or logger
          git_keymaps_module.register(wk, keymap_logger)
          logger.info("Git related keymaps from 'keymaps.which-key.git' registered with which-key.")
        else
          logger.warn("Failed to load or register Git keymaps from 'keymaps.which-key.git'. Error: " .. tostring(git_keymaps_module))
        end
      else
        logger.warn("'which-key' module not available. Git keymaps for which-key skipped. Error: " .. tostring(wk))
      end
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ ↔️ Diffview (Advanced Git diff tool)                    │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    -- No specific config function needed if defaults are fine and keymaps are handled by keymaps/which-key/git.lua
    -- If you need to call diffview.setup({}), add a config function.
    -- config = true, -- This would just call require("diffview").setup({})
    config = function()
        local logger_dv
        local cd_ok_dv, cd_dv = pcall(require, "core.debug")
        if cd_ok_dv and cd_dv and cd_dv.get_logger then
            logger_dv = cd_dv.get_logger("plugins.diffview")
        else
            logger_dv = { info = function(m) print("INFO [DiffviewP_FB]: " .. m) end }
            logger_dv.info("core.debug.get_logger not found. Using fallback for diffview config.")
        end
        logger_dv.info("sindrets/diffview.nvim loaded (default setup). Keymaps in keymaps/which-key/git.lua.")
        -- require("diffview").setup({}) -- Call if you have specific diffview opts
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🔨 Fugitive (Git wrapper - The Hammer)                   │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull", "Gcommit", "Gdiffsplit" }, -- Add more fugitive commands
    dependencies = {
      "tpope/vim-rhubarb", -- For GitHub integration (e.g., :GBrowse)
    },
    config = function()
        local logger_fug
        local cd_ok_fug, cd_fug = pcall(require, "core.debug")
        if cd_ok_fug and cd_fug and cd_fug.get_logger then
            logger_fug = cd_fug.get_logger("plugins.fugitive")
        else
            logger_fug = { info = function(m) print("INFO [FugitiveP_FB]: " .. m) end }
            logger_fug.info("core.debug.get_logger not found. Using fallback for fugitive config.")
        end
        logger_fug.info("tpope/vim-fugitive loaded. Keymaps in keymaps/which-key/git.lua.")
        -- Fugitive is mostly command-based, specific setup rarely needed here.
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 📄 Templ (GitLab CI/CD YAML support)                     │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "joerdav/templ.vim", -- Note: This seems to be a generic template plugin, not specific to GitLab CI.
                         -- If it's for Go templates, the ft might be "templ".
                         -- For GitLab CI, you might need a dedicated YAML LSP setup or schema.
    ft = { "yaml", "yml", "gitlab-ci" }, -- Added "gitlab-ci" directly
    config = function()
      local logger_tpl
      local cd_ok_tpl, cd_tpl = pcall(require, "core.debug")
      if cd_ok_tpl and cd_tpl and cd_tpl.get_logger then
        logger_tpl = cd_tpl.get_logger("plugins.templ")
      else
        logger_tpl = { info = function(m) print("INFO [TemplP_FB]: " .. m) end }
        logger_tpl.info("core.debug.get_logger not found. Using fallback for templ.vim config.")
      end

      logger_tpl.info("Configuring joerdav/templ.vim (or GitLab CI filetype association)...")
      vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        pattern = { "*.gitlab-ci.yml", ".gitlab-ci.yml" },
        callback = function(args)
          vim.bo[args.buf].filetype = "gitlab-ci"
          logger_tpl.info("Set filetype to 'gitlab-ci' for " .. args.file)
        end,
        desc = "Set filetype for GitLab CI YAML files",
      })
      -- If templ.vim is for Go templates, you might need:
      -- vim.cmd("runtime! ftplugin/templ.vim")
    end,
  },
}

