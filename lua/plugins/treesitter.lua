-- nvim/lua/plugins/treesitter.lua
-- Plugin specifications for nvim-treesitter and related extensions.

return {
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🌳 Core Treesitter & Syntax-Aware Features               │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Command to update parsers
    event = { "BufReadPost", "BufNewFile" }, -- Load early for highlighting and other features
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Additional textobjects
      "windwp/nvim-ts-autotag",                     -- Autoclose and rename HTML/XML tags
      "nvim-treesitter/nvim-treesitter-context",    -- Show context of the current code block
      -- "JoosepAlviste/nvim-ts-context-commentstring", -- Handled as a separate plugin spec below
      -- "RRethy/nvim-treesitter-endwise", -- if you want endwise for Ruby, Lua, etc.
      -- "RRethy/nvim-treesitter-textsubjects", -- For more advanced text subjects
    },
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.treesitter.core")
      else
        logger = { info = function(m) print("INFO [TS_P_Core_FB]: " .. m) end, error = function(m) print("ERROR [TS_P_Core_FB]: " .. m) end, warn = function(m) print("WARN [TS_P_Core_FB]: " .. m) end, debug = function(m) print("DEBUG [TS_P_Core_FB]: " .. m) end }
        logger.error("core.debug.get_logger not found. Using fallback for nvim-treesitter config.")
      end

      logger.info("Configuring nvim-treesitter/nvim-treesitter...")

      local ts_configs_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if not ts_configs_ok then
        logger.error("Failed to load 'nvim-treesitter.configs'. Treesitter setup aborted. Error: " .. tostring(ts_configs))
        return
      end

      ts_configs.setup({
        ensure_installed = { -- List of parsers to ensure are installed
          "bash", "c", "cpp", "css", "dockerfile", "go", "gomod", "gosum", -- Added gomod, gosum
          "html", "javascript", "json", "jsonc", -- Added jsonc
          "lua", "luadoc", "luap", -- Added luadoc, luap (lua patterns)
          "make", "markdown", "markdown_inline",
          "python", "query", "regex", "ruby", "rust", "sql", "svelte",
          "terraform", "hcl", -- Added hcl for terraform
          "tsx", "typescript", "vim", "vimdoc", "yaml",
          -- Consider adding: "comment" (for //TODO: comments), "toml", "php", "java" based on your needs
        },
        sync_install = false, -- Install parsers asynchronously
        auto_install = true,  -- Automatically install missing parsers when entering a buffer
        ignore_install = {},  -- List of parsers to ignore installing

        highlight = {
          enable = true,
          -- disable = { "c", "rust" }, -- Example: disable highlighting for specific languages
          additional_vim_regex_highlighting = false, -- Use Treesitter only for highlighting
        },
        indent = { enable = true }, -- Enable Treesitter-based indentation
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>", -- Start incremental selection
            node_incremental = "<C-space>", -- Increment to next bigger node
            scope_incremental = "<nop>", -- Disabled <C-s> to avoid conflict with save or other bindings
            node_decremental = "<bs>", -- Decrement selection (was <C-BS>)
          },
        },
        autotag = { enable = true }, -- For nvim-ts-autotag (HTML/XML tag closing/renaming)
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Look ahead for more complex text objects
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer", ["if"] = "@function.inner",
              ["ac"] = "@class.outer", ["ic"] = "@class.inner",
              ["al"] = "@loop.outer", ["il"] = "@loop.inner",
              ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
              ["ib"] = "@block.outer", ["ab"] = "@block.inner", -- Or @conditional.outer/inner, @comment.outer/inner etc.
              ["is"] = "@statement.outer", -- Select current statement
              ["a="] = "@assignment.outer", ["i="] = "@assignment.inner", -- Example: assignment
              ["a:"] = "@property.outer", ["i:"] = "@property.inner",   -- Example: key-value pair / property
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- Whether to set jumps in the jumplist
            goto_next_start = {
              ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]s"] = "@statement.outer", ["]p"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]S"] = "@statement.outer", ["]P"] = "@parameter.inner",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[s"] = "@statement.outer", ["[p"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[S"] = "@statement.outer", ["[P"] = "@parameter.inner",
            },
          },
          swap = {
            enable = true,
            swap_next = { ["<leader>swa"] = "@parameter.inner" }, -- Example: <leader> + s(wap) + a(rgument)
            swap_previous = { ["<leader>swA"] = "@parameter.inner" },
          },
        },
        -- playground = { enable = true }, -- For Treesitter playground, useful for query development
      })
      logger.debug("nvim-treesitter.configs.setup() completed.")

      -- Configure nvim-treesitter-context
      local ts_context_ok, ts_context = pcall(require, "treesitter-context")
      if ts_context_ok and ts_context then
        ts_context.setup({
          enable = true, max_lines = 3, min_window_height = 0, -- 0 means no minimum height
          trim_scope = "outer",
          patterns = {
            default = {
              "class", "function", "method", "for", "while", "if", "switch", "case",
              "loop", "try", "catch", "interface", "struct", "enum", "module", "impl",
              -- Add more patterns if needed for specific languages
            },
          },
          zindex = 20, mode = "cursor", separator = nil, -- No separator line
        })
        logger.debug("nvim-treesitter-context configured.")
      else
        logger.warn("nvim-treesitter-context not found or failed to load. Error: " .. tostring(ts_context))
      end
      logger.info("nvim-treesitter and core extensions configured successfully.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ ✍️ Treesitter Context Commentstring                      │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" }, -- Load after Treesitter
    config = function()
      local logger_ccs
      local core_debug_ok_ccs, core_debug_ccs = pcall(require, "core.debug")
      if core_debug_ok_ccs and core_debug_ccs and core_debug_ccs.get_logger then
        logger_ccs = core_debug_ccs.get_logger("plugins.ts-context-commentstring")
      else
        logger_ccs = { info = function(m) print("INFO [TS_CCS_P_FB]: " .. m) end, error = function(m) print("ERROR [TS_CCS_P_FB]: " .. m) end }
        logger_ccs.error("core.debug.get_logger not found for nvim-ts-context-commentstring.")
      end

      logger_ccs.info("Configuring nvim-ts-context-commentstring...")

      -- This plugin relies on the 'commentstring' option being set correctly by filetype plugins.
      -- It enhances how plugins like vim-commentary or Comment.nvim determine the commentstring.
      -- The global variable is to prevent this plugin from setting up the default commentstring handling
      -- if you are using another plugin for that (like Comment.nvim's integration).
      vim.g.skip_ts_context_commentstring_module = true -- If you use Comment.nvim or similar that handles this.
                                                      -- Set to false if you want this plugin to be the primary source for context-aware commentstring.

      local ts_ccs_ok, ts_ccs = pcall(require, "ts_context_commentstring")
      if ts_ccs_ok and ts_ccs then
        ts_ccs.setup({
          enable_autocmd = false, -- Recommended false if you use a dedicated commenting plugin like Comment.nvim or mini.comment
          custom_calculation = nil, -- function(node, language_tree) -> string | nil
        })
        logger_ccs.info("nvim-ts-context-commentstring configured.")
      else
        logger_ccs.error("Failed to load 'ts_context_commentstring'. Error: " .. tostring(ts_ccs))
      end
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 📦 Package Info (for package.json)                       │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "BufReadPost package.json", -- Load only when package.json is opened
    config = function()
      local logger_pkg
      local core_debug_ok_pkg, core_debug_pkg = pcall(require, "core.debug")
      if core_debug_ok_pkg and core_debug_pkg and core_debug_pkg.get_logger then
        logger_pkg = core_debug_pkg.get_logger("plugins.package-info")
      else
        logger_pkg = { info = function(m) print("INFO [PkgInfoP_FB]: " .. m) end, error = function(m) print("ERROR [PkgInfoP_FB]: " .. m) end }
        logger_pkg.error("core.debug.get_logger not found for package-info.nvim.")
      end

      logger_pkg.info("Configuring vuki656/package-info.nvim...")
      local pkg_info_ok, pkg_info = pcall(require, "package-info")
      if pkg_info_ok and pkg_info then
        pkg_info.setup({
          -- Default options are usually fine. Customize as needed.
          -- colors = { latest = "#C3E88D", outdated = "#FFCB6B", error = "#F07178" },
          -- package_manager = "npm", -- "npm", "yarn", "pnpm", "bun"
          -- hide_up_to_date = false,
          -- calculating_text = "Calculating...",
          -- version_prefix = "v",
        })
        logger_pkg.info("package-info.nvim configured.")
      else
        logger_pkg.error("Failed to load 'package-info' module. Error: " .. tostring(pkg_info))
      end
    end,
  },
}

