-- plugins/which-key.lua
local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.which-key")) or fallback

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")

    wk.setup({
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
      },
      key_labels = {
        ["<leader>"] = "󱁐",
      },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      popup_mappings = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      window = {
        border = "single",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 1, 1, 1, 1 },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      ignore_missing = true,
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
      show_help = true,
      show_keys = true,
      triggers = "auto",
      disable = {
        buftypes = {},
        filetypes = { "TelescopePrompt" },
      },
    })

    -- LSP configuration via Mason + lspconfig
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local lspconfig = require("lspconfig")

    mason.setup()
    mason_lspconfig.setup({
      ensure_installed = {
        "dockerls", "azure_pipelines_ls", "cssls", "denols",
        "docker_compose_language_service", "emmet_ls", "eslint", "gopls",
        "graphql", "helm_ls", "html", "jsonls", "lua_ls",
        "nixfmt", "oelint-adv", "ols", "prismals", "pyright",
        "ruff", "rust_analyzer", "tailwindcss", "tflint",
        "tsserver", "solidity_ls", "yamlls"
      },
    })

    local on_attach = function(client, bufnr)
      local bufmap = function(mode, lhs, rhs, desc)
        if desc then desc = "LSP: " .. desc end
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- LSP default keymaps
      bufmap('n', 'gd', vim.lsp.buf.definition, 'Goto Definition')
      bufmap('n', 'K', vim.lsp.buf.hover, 'Hover')
      bufmap('n', 'gi', vim.lsp.buf.implementation, 'Goto Implementation')
      bufmap('n', '[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')
      bufmap('n', ']d', vim.diagnostic.goto_next, 'Next Diagnostic')

      -- Which-key LSP menu under <leader>l
      wk.register({
        l = {
          name = "LSP",
          i = { "<cmd>LspInfo<cr>",        "Info" },
          I = { "<cmd>Mason<cr>",          "Installer Info" },
          r = { vim.lsp.buf.rename,        "Rename" },
          a = { vim.lsp.buf.code_action,   "Code Action" },
          f = { function() vim.lsp.buf.format({ async = true }) end, "Format" },
          d = { vim.diagnostic.open_float, "Line Diagnostics" },
          q = { vim.diagnostic.setloclist, "Quickfix Diagnostics" },
        },
      }, { prefix = "<leader>" })
    end

    mason_lspconfig.setup_handlers({
      function(server_name)
        lspconfig[server_name].setup {
          on_attach = on_attach,
          flags = { debounce_text_changes = 150 },
        }
      end
    })

    -- DAP configuration with which-key
    local dap = require("dap")

    wk.register({
      d = {
        name = "Debug",
        r = { function() dap.continue() end,           "Run/Continue" },
        b = { function() dap.toggle_breakpoint() end,  "Toggle Breakpoint" },
        c = { function() dap.run_to_cursor() end,      "Run to Cursor" },
        s = { function() dap.step_over() end,          "Step Over" },
        i = { function() dap.step_into() end,          "Step Into" },
        o = { function() dap.step_out() end,           "Step Out" },
        u = { function() dap.up() end,                 "Up Frame" },
        d = { function() dap.down() end,               "Down Frame" },
        l = { function() dap.toggle_repl() end,        "Toggle REPL" },
      },
    }, { prefix = "<leader>" })

    -- Forensic group (disabled by default)
    wk.register({
      f = {
        name = "Forensic",
        -- Add forensic commands here, e.g.:
        -- a = { "<cmd>ForensicAnalyze<cr>", "Analyze" },
        -- r = { "<cmd>ForensicReport<cr>", "Report" },
      },
    }, { prefix = "<leader>" })

    logger.info("which-key configurado com sucesso.")
  end,
}