-- nvim/lua/plugins/treesitter.lua
-- Plugin specifications for nvim-treesitter and related extensions.
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.treesitter")) or fallback
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
      "windwp/nvim-ts-autotag",                      -- Autoclose and rename HTML/XML tags
      "nvim-treesitter/nvim-treesitter-context",     -- Show context of the current code block
    },
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
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
        ensure_installed = {
          "bash", "c", "cpp", "css", "dockerfile", "go", "gomod", "gosum",
          "html", "javascript", "json", "jsonc",
          "lua", "luadoc", "luap",
          "make", "markdown", "markdown_inline",
          "python", "query", "regex", "ruby", "rust", "sql", "svelte",
          "terraform", "hcl",
          "tsx", "typescript", "vim", "vimdoc", "yaml",
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {},

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<nop>",
            node_decremental = "<bs>",
          },
        },
        autotag = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer", ["if"] = "@function.inner",
              ["ac"] = "@class.outer", ["ic"] = "@class.inner",
              ["al"] = "@loop.outer", ["il"] = "@loop.inner",
              ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
              ["ib"] = "@block.outer", ["ab"] = "@block.inner",
              ["is"] = "@statement.outer",
              ["a="] = "@assignment.outer", ["i="] = "@assignment.inner",
              ["a:"] = "@property.outer", ["i:"] = "@property.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
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
            swap_next = { ["<leader>swa"] = "@parameter.inner" },
            swap_previous = { ["<leader>swA"] = "@parameter.inner" },
          },
        },
      })
      logger.debug("nvim-treesitter.configs.setup() completed.")

      local ts_context_ok, ts_context = pcall(require, "treesitter-context")
      if ts_context_ok and ts_context then
        ts_context.setup({
          enable = true, max_lines = 3, min_window_height = 0,
          trim_scope = "outer",
          patterns = {
            default = {
              "class", "function", "method", "for", "while", "if", "switch", "case",
              "loop", "try", "catch", "interface", "struct", "enum", "module", "impl",
            },
          },
          zindex = 20, mode = "cursor", separator = nil,
        })
        logger.debug("nvim-treesitter-context configured.")
      else
        logger.warn("nvim-treesitter-context not found or failed to load. Error: " .. tostring(ts_context))
      end
      logger.info("nvim-treesitter and core extensions configured successfully.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ ✍️ Treesitter Context Commentstring                       │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local logger_ccs
      -- Corrigido: Usar core.debug.logger consistentemente
      local core_debug_ok_ccs, core_debug_ccs = pcall(require, "core.debug.logger")
      if core_debug_ok_ccs and core_debug_ccs and core_debug_ccs.get_logger then
        logger_ccs = core_debug_ccs.get_logger("plugins.ts-context-commentstring")
      else
        logger_ccs = { info = function(m) print("INFO [TS_CCS_P_FB]: " .. m) end, error = function(m) print("ERROR [TS_CCS_P_FB]: " .. m) end, warn = function(m) print("WARN [TS_CCS_P_FB]: " .. m) end }
        logger_ccs.error("core.debug.logger not found for nvim-ts-context-commentstring.")
      end

      logger_ccs.info("Configuring nvim-ts-context-commentstring...")
      vim.g.skip_ts_context_commentstring_module = true

      local ts_ccs_ok, ts_ccs = pcall(require, "ts_context_commentstring")
      if ts_ccs_ok and ts_ccs then
        ts_ccs.setup({
          enable_autocmd = false,
          custom_calculation = nil,
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
    event = "BufReadPost package.json",
    config = function()
      local logger_pkg
      -- Corrigido: Usar core.debug.logger consistentemente
      local core_debug_ok_pkg, core_debug_pkg = pcall(require, "core.debug.logger")
      if core_debug_ok_pkg and core_debug_pkg and core_debug_pkg.get_logger then
        logger_pkg = core_debug_pkg.get_logger("plugins.package-info")
      else
        logger_pkg = { info = function(m) print("INFO [PkgInfoP_FB]: " .. m) end, error = function(m) print("ERROR [PkgInfoP_FB]: " .. m) end, warn = function(m) print("WARN [PkgInfoP_FB]: " .. m) end }
        logger_pkg.error("core.debug.logger not found for package-info.nvim.")
      end

      logger_pkg.info("Configuring vuki656/package-info.nvim...")
      local pkg_info_ok, pkg_info = pcall(require, "package-info")
      if pkg_info_ok and pkg_info then
        pkg_info.setup({})
        logger_pkg.info("package-info.nvim configured.")
      else
        logger_pkg.error("Failed to load 'package-info' module. Error: " .. tostring(pkg_info))
      end
    end,
  },
}

