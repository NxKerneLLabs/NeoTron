-- ~/.config/nvim/lua/plugins/which-key-lsp.lua

local wk = require("which-key")

-- Core setup
wk.setup({
  -- "auto" captures <leader>, g, /, :, etc.
  triggers    = "auto",
  show_help   = true,
  show_keys   = true,
  disable     = {
    buftypes  = {},
    filetypes = { "TelescopePrompt" },
  },
  key_labels = {
    ["<leader>"] = "󱁐",  -- icon for <leader>
  },
  -- Example filter for tree view
  tree = {
    filter = function(node)
      -- remove internal commands starting with '_'
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
