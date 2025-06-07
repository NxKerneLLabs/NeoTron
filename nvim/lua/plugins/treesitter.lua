-- nvim/lua/plugins/treesitter.lua
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

      local ts_configs_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if not ts_configs_ok then
        logger.error("Failed to load 'nvim-treesitter.configs'. Treesitter setup aborted. Error: " .. tostring(ts_configs))
        return
      end

      -- Add safety wrapper for treesitter setup
      local success, error_msg = pcall(function()
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
            -- Add safety check for missing parsers
            disable = function(lang, buf)
              -- Disable for very large files
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
              
              -- Check if parser is available
              local parser_available = pcall(vim.treesitter.get_parser, buf, lang)
              if not parser_available then
                logger.warn("Parser for " .. lang .. " not available, disabling highlight")
                return true
              end
              
              return false
            end,
          },
          indent = { 
            enable = true,
            -- Disable indent for problematic languages
            disable = { "python", "yaml" },
          },
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
      end)

      if not success then
        logger.error("Failed to setup treesitter: " .. tostring(error_msg))
        return
      end

      logger.debug("nvim-treesitter.configs.setup() completed.")

      -- Setup treesitter-context with error handling
      local ts_context_ok, ts_context = pcall(require, "treesitter-context")
      if ts_context_ok and ts_context then
        local context_success, context_error = pcall(function()
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
        end)
        

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ ✍️ Treesitter Context Commentstring                       │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },

      vim.g.skip_ts_context_commentstring_module = true

      local ts_ccs_ok, ts_ccs = pcall(require, "ts_context_commentstring")
        
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 📦 Package Info (for package.json)                       │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "BufReadPost package.json",
    config = function()
     
