-- nvim/lua/plugins/lsp.lua corrigido
-- Plugin specifications for LSP, Mason, linters, formatters, and diagnostics.

return {
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🤖 LSP Core Configuration                                  │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- Load LSP features early
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "b0o/schemastore.nvim",
      "folke/neodev.nvim",
      {
        "ray-x/lsp_signature.nvim",
        opts = {
          bind = true,
          handler_opts = { border = "rounded" },
          hint_enable = false,
        },
        event = "LspAttach", -- Load on LspAttach for optimization
      },
      -- "folke/which-key.nvim", -- Já não é uma dependência direta aqui para registo de keymaps
      "SmiteshP/nvim-navic",  -- For breadcrumbs in Lualine/statusline
      "hrsh7th/cmp-nvim-lsp", -- For nvim-cmp capabilities
    },
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug.logger")
      if core_debug_ok and core_debug and core_debug.get_logger then
        logger = core_debug.get_logger("plugins.lsp.config")
      else
        logger = { info = function(m) print("INFO [LSP_P_FB]: " .. m) end, error = function(m) print("ERROR [LSP_P_FB]: " .. m) end, warn = function(m) print("WARN [LSP_P_FB]: " .. m) end, debug = function(m) print("DEBUG [LSP_P_FB]: " .. m) end }
        logger.error("core.debug.get_logger not found. Using fallback for nvim-lspconfig.")
      end

      logger.info("Configuring nvim-lspconfig and its ecosystem...")

      -- 1. Configure Neodev (for Lua development in Neovim)
      local neodev_ok, neodev = pcall(require, "neodev")
      if neodev_ok and neodev then
        neodev.setup({
          library = { enabled = true, runtime = true, plugins = true, types = true },
          setup_jsonls = true,
          lspconfig = true,
        })
        logger.debug("neodev.nvim configured.")
      else
        logger.warn("neodev.nvim not found or failed to load. Error: " .. tostring(neodev))
      end

      -- 2. Configure Diagnostic Icons and Appearance
      local icons_ok, icons_utils = pcall(require, "utils.icons")
      if icons_ok and icons_utils and icons_utils.diagnostics then
        for name, icon in pairs(icons_utils.diagnostics) do
          local sign_name = "DiagnosticSign" .. name:gsub("^%l", string.upper) -- Capitalize first letter for convention
          local hl_group = "DiagnosticSign" .. name:gsub("^%l", string.upper)
          vim.fn.sign_define(sign_name, { text = icon, texthl = hl_group, numhl = "" })
        end
        logger.debug("Diagnostic signs configured with custom icons.")
      else
        logger.warn("utils.icons.diagnostics not found. Using default diagnostic signs. Error: " .. tostring(icons_utils))
        vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
        vim.fn.sign_define("DiagnosticSignWarn",  { text = "", texthl = "DiagnosticSignWarn" })
        vim.fn.sign_define("DiagnosticSignInfo",  { text = "", texthl = "DiagnosticSignInfo" })
        vim.fn.sign_define("DiagnosticSignHint",  { text = "", texthl = "DiagnosticSignHint" })
      end

      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●", severity_limit = vim.diagnostic.severity.WARN },
        severity_sort = true,
        float = { border = "rounded", source = "always", focusable = true },
      })
      logger.debug("vim.diagnostic.config applied.")

      -- 3. Define LSP Server Configurations
      local servers = {
        dockerls = {}, docker_compose_language_service = {}, azure_pipelines_ls = {},
        terraformls = { filetypes = {"terraform", "tf", "tfvars"} }, tflint = {}, helm_ls = {},
        yamlls = {
          settings = { yaml = { schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "**/docker-compose*.yml",
            ["kubernetes"] = "**/k8s/**/*.yml",
          }}},
        },
        html = {}, cssls = {}, jsonls = {
          settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } }
        },
        tsserver = { settings = { typescript = { inlayHints = {
          includeInlayParameterNameHints = "all", includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true, includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true, includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }}, javascript = { inlayHints = {
          includeInlayParameterNameHints = "all", includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true, includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true, includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }}}},
        eslint = { settings = { workingDirectories = { { mode = "auto" } } } },
        denols = { init_options = { lint = true, unstable = true } },
        emmet_ls = {},
        tailwindcss = {},
        pyright = { settings = { python = { analysis = {
          typeCheckingMode = "basic", autoSearchPaths = true,
          useLibraryCodeForTypes = true, diagnosticMode = "workspace",
        }}}},
        ruff_lsp = {},
        lua_ls = { settings = { Lua = {
          workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
          completion = { callSnippet = "Replace" },
          telemetry = { enable = false },
          diagnostics = { globals = { "vim" } },
          hint = { enable = true, setType = true },
        }}},
        graphql = {}, prismals = {}, gopls = {
          settings = { gopls = {analyses = {unusedparams = true}, staticcheck = true }}
        },
        solidity_ls = {},
        rust_analyzer = { settings = { ["rust-analyzer"] = {
          cargo = { allFeatures = true, loadOutDirsFromCheck = true },
          checkOnSave = { command = "clippy" },
          procMacro = { enable = true },
        }}},
      }
      logger.debug("LSP server configurations defined for " .. vim.inspect(vim.tbl_keys(servers)))

      -- 4. Configure Mason
      local mason_ok, mason = pcall(require, "mason")
      if mason_ok and mason then
        mason.setup({
          ui = { border = "rounded", icons = {
            package_installed = icons_ok and icons_utils and icons_utils.ui and icons_utils.ui.CheckboxChecked or "✓",
            package_pending = icons_ok and icons_utils and icons_utils.ui and icons_utils.ui.ArrowRight or "➜",
            package_uninstalled = icons_ok and icons_utils and icons_utils.ui and icons_utils.ui.CheckboxUnchecked or "✗",
          }},
        })
        logger.debug("mason.nvim configured.")
      else
        logger.warn("mason.nvim not found or failed to load. Error: " .. tostring(mason))
      end

      -- 5. Configure Mason-LSPConfig (CORRIGIDO)
      local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
      if mason_lspconfig_ok and mason_lspconfig then
        mason_lspconfig.setup({
          ensure_installed = vim.tbl_keys(servers),
          -- CORREÇÃO: Remover automatic_installation que está causando o problema
          -- automatic_installation = true,
        })
        logger.debug("mason-lspconfig.nvim configured to ensure installation of listed servers.")
      else
        logger.warn("mason-lspconfig.nvim not found or failed to load. Error: " .. tostring(mason_lspconfig))
      end

      -- 6. Define LSP Client Capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if cmp_nvim_lsp_ok and cmp_nvim_lsp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      else
        logger.warn("cmp-nvim-lsp not found. Using default LSP capabilities. Error: " .. tostring(cmp_nvim_lsp))
      end
      capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

      -- Corrigido para usar verificação de versão mais adequada para inlayHint
      if vim.fn.has('nvim-0.10') == 1 or (vim.lsp and vim.lsp.inlay_hint) then
        if capabilities.textDocument and capabilities.textDocument.inlayHint == nil then
            capabilities.textDocument.inlayHint = { dynamicRegistration = true }
        end
        if capabilities.workspace and capabilities.workspace.inlayHint == nil then
            capabilities.workspace.inlayHint = { refreshSupport = true }
        end
        logger.debug("Inlay hint capabilities added/ensured.")
      else
        logger.debug("Neovim version doesn't support inlay hints or feature not available.")
      end
      logger.debug("LSP client capabilities configured.")

      -- 7. Define on_attach function
      local on_attach = function(client, bufnr)
        logger.info("LSP attached: " .. client.name .. " to buffer " .. bufnr)

        if client.server_capabilities.documentSymbolProvider then
          local navic_ok_attach, navic_attach = pcall(require, "nvim-navic")
          if navic_ok_attach and navic_attach then
            navic_attach.attach(client, bufnr)
            logger.debug("nvim-navic attached to " .. client.name)
          else
            logger.warn("nvim-navic not found or failed to load in on_attach. Error: " .. tostring(navic_attach))
          end
        end
      end
      logger.debug("Global on_attach function defined for LSPs.")

      -- 8. Setup LSP Servers using mason_lspconfig handlers
      local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
      if not lspconfig_ok then
        logger.error("lspconfig module not found. Cannot setup LSP servers. Error: " .. tostring(lspconfig))
        return -- Critical failure
      end

      if mason_lspconfig_ok and mason_lspconfig then
        mason_lspconfig.setup_handlers({
          function(server_name) -- Default handler for all servers
            local server_user_opts = servers[server_name] or {}
            local final_opts = vim.tbl_deep_extend("force", {
              capabilities = capabilities,
              on_attach = on_attach,
            }, server_user_opts)

            lspconfig[server_name].setup(final_opts)
            logger.debug("LSP server '" .. server_name .. "' setup with final options.")
          end,
        })
      else
        logger.warn("mason-lspconfig not available. Manually setting up listed LSP servers.")
        for server_name_fallback, server_user_opts_fallback in pairs(servers) do
          local final_opts_fallback = vim.tbl_deep_extend("force", {
            capabilities = capabilities,
            on_attach = on_attach,
          }, server_user_opts_fallback or {})
          if lspconfig[server_name_fallback] then
            lspconfig[server_name_fallback].setup(final_opts_fallback)
            logger.debug("LSP server '" .. server_name_fallback .. "' (manual fallback) setup with final options.")
          else
            logger.warn("LSP config for server '" .. server_name_fallback .. "' not found in lspconfig module.")
          end
        end
      end

      logger.info("nvim-lspconfig and its ecosystem configured successfully.")
    end,
  },

  -- Sem alterações nas outras seções do código...
  -- Resto do arquivo permanece igual
}
