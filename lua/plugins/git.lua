-- nvim/lua/plugins/git.lua
-- Plugin specifications for Git integration: gitsigns, diffview, fugitive, and templ (GitLab CI).
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.git")) or fallback
return {
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 📊 Gitsigns (Git decorations in the signcolumn)          │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- Load early for signs and blame
    -- dependencies = { "folke/which-key.nvim" }, -- Removido: which-key é gerido centralmente
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.gitsigns")
      else
        logger = { info = function(m) print("INFO [GitSignsP_FB]: " .. m) end, error = function(m) print("ERROR [GitSignsP_FB]: " .. m) end, warn = function(m) print("WARN[GitSignsP_FB]: " .. m) end, debug = function(m) print("DEBUG [GitSignsP_FB]: " .. m) end }
        logger.error("core.debug.get_logger not found. Using fallback for gitsigns config.")
      end

      logger.info("Configuring lewis6991/gitsigns.nvim...")

      local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
      if not gitsigns_ok then
        logger.error("Failed to load 'gitsigns' module. Setup aborted. Error: " .. tostring(gitsigns))
        return
      end

      local icons_ok, icons_utils = pcall(require, "utils.icons")
      local signs_config = { -- Renomeado para signs_config para evitar conflito com a variável global signs
        add = { text = "▎" }, change = { text = "▎" }, delete = { text = "▎" },
        topdelete = { text = "▎" }, changedelete = { text = "▎" }, untracked = { text = "▎" },
       }
    end

      if icons_ok and icons_utils and icons_utils.git then
        signs_config.add          = { text = icons_utils.git.GitSignsAdd or "▎A" }
        signs_config.change       = { text = icons_utils.git.GitSignsChange or "▎M" }
        signs_config.delete       = { text = icons_utils.git.GitSignsDelete or "▎D" }
        signs_config.topdelete    = { text = icons_utils.git.GitSignsTopDelete or "▎TD" }
        signs_config.changedelete = { text = icons_utils.git.GitSignsChangeDelete or "▎CD" }
        signs_config.untracked    = { text = icons_utils.git.Untracked or "▎U" }
        logger.debug("Using custom icons for gitsigns.")
      else
        logger.warn("utils.icons.git not found for gitsigns. Using default text signs. Error: " .. tostring(icons_utils))
     end

      gitsigns.setup({
        signs = signs_config,
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
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            opts.silent = true
            vim.keymap.set(mode, l, r, opts)
          end

          map("n", "]c", function() if vim.wo.diff then return "]c" end; vim.schedule(gs.next_hunk); return "<Ignore>" end, { expr = true, desc = "Next Git Hunk" })
          map("n", "[c", function() if vim.wo.diff then return "[c" end; vim.schedule(gs.prev_hunk); return "<Ignore>" end, { expr = true, desc = "Previous Git Hunk" })

          map("n", "<leader>hs", gs.stage_hunk, { desc = "Git: Stage Hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { desc = "Git: Reset Hunk" })
          map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Git: Stage Selected Hunks" })
          map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Git: Reset Selected Hunks" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "Git: Stage Buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Git: Undo Stage Hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "Git: Reset Buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Git: Preview Hunk" })
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Git: Blame Line" })
          map("n", "<leader>hB", gs.toggle_current_line_blame, { desc = "Git: Toggle Line Blame" })
          map("n", "<leader>hd", function() gs.diffthis("~") end, { desc = "Git: Diff This ~" })
          map("n", "<leader>hD", function() gs.diffthis("@") end, { desc = "Git: Diff This @" })
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Git: Select Hunk (Text Object)" })
        end,
      })
      logger.info("gitsigns.nvim configured.")

      -- REMOVIDO: Bloco de registo de keymaps do Gitsigns com which-key.
      -- Esta responsabilidade foi movida para o orquestrador de keymaps (lua/keymaps/init.lua)
      -- e para o ficheiro de definição (lua/keymaps/definitions/git.lua).
      -- logger.info("Gitsigns keymap registration with which-key will be handled by the central keymap orchestrator.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ ↔️ Diffview (Advanced Git diff tool)                      │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    config = function()
        local logger_dv
        -- Corrigido o caminho do require para o logger
        local cd_ok_dv, cd_dv = pcall(require, "core.debug.logger")
        if cd_ok_dv and cd_dv and cd_dv.get_logger then
            logger_dv = cd_dv.get_logger("plugins.diffview")
        else
            logger_dv = { info = function(m) print("INFO [DiffviewP_FB]: " .. m) end, error = function(m) print("ERROR [DiffviewP_FB]: " .. m) end }
            logger_dv.error("core.debug.logger not found. Using fallback for diffview config.")
        end
        logger_dv.info("sindrets/diffview.nvim loaded (default setup). Keymaps in lua/keymaps/definitions/git.lua.")
        -- require("diffview").setup({}) -- Descomente e configure se precisar de opções específicas para diffview
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🔨 Fugitive (Git wrapper - The Hammer)                   │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull", "Gcommit", "Gdiffsplit" },
    dependencies = {
      "tpope/vim-rhubarb", -- For GitHub integration (e.g., :GBrowse)
    },
    config = function()
        local logger_fug
        local cd_ok_fug, cd_fug = pcall(require, "core.debug.logger")
        if cd_ok_fug and cd_fug and cd_fug.get_logger then
            logger_fug = cd_fug.get_logger("plugins.fugitive")
        else
            logger_fug = { info = function(m) print("INFO [FugitiveP_FB]: " .. m) end, error = function(m) print("ERROR [FugitiveP_FB]: " .. m) end }
            logger_fug.error("core.debug.logger not found. Using fallback for fugitive config.")
        end
        logger_fug.info("tpope/vim-fugitive loaded. Keymaps in lua/keymaps/definitions/git.lua.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 📄 Templ (GitLab CI/CD YAML support)                     │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "joerdav/templ.vim",
    ft = { "yaml", "yml", "gitlab-ci" },
    config = function()
      local logger_tpl
      local cd_ok_tpl, cd_tpl = pcall(require, "core.debug.logger")
      if cd_ok_tpl and cd_tpl and cd_tpl.get_logger then
        logger_tpl = cd_tpl.get_logger("plugins.templ")
      else
        logger_tpl = { info = function(m) print("INFO [TemplP_FB]: " .. m) end, error = function(m) print("ERROR [TemplP_FB]: " .. m) end }
        logger_tpl.error("core.debug.logger not found. Using fallback for templ.vim config.")
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
    end,
  },
}

