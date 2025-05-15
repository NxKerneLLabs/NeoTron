-- ~/.config/nvim/lua/plugins/which-key-config.lua

local wk = require("which-key")

-- Core setup
wk.setup({
  -- Deixe em "auto" para capturar <leader>, g, /, :, etc.
  triggers    = "auto",
  show_help   = true,
  show_keys   = true,
  disable     = {
    buftypes  = {},
    filetypes = { "TelescopePrompt" },
  },
  key_labels = {
    ["<leader>"] = "󱁐",  -- ícone para <leader>
  },
  -- Exemplo de filter para tree view
  tree = {
    filter = function(node)
      -- remove comandos internos que começam com '_'
      return not vim.startswith(node.label or "", "_")
    end,
    icons = { file = "", folder_closed = "", folder_open = "" },
    indent = 2,
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
    "ts_ls", "solidity_ls", "yamlls"
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
      I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
      r = { vim.lsp.buf.rename,         "Rename" },
      a = { vim.lsp.buf.code_action,   "Code Action" },
      f = { function() vim.lsp.buf.format { async = true } end, "Format" },
      d = { vim.diagnostic.open_float,  "Line Diagnostics" },
      q = { vim.diagnostic.setloclist,  "Quickfix Diagnostics" },
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
    r = { dap.continue,     "Run/Continue" },
    b = { dap.toggle_breakpoint, "Toggle Breakpoint" },
    c = { dap.run_to_cursor, "Run to Cursor" },
    s = { dap.step_over,     "Step Over" },
    i = { dap.step_into,     "Step Into" },
    o = { dap.step_out,      "Step Out" },
    u = { dap.up,            "Up Frame" },
    d = { dap.down,          "Down Frame" },
    l = { dap.toggle_repl,   "Toggle REPL" },
  },
}, { prefix = "<leader>" })
