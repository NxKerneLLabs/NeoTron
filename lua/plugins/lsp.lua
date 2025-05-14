-- nvim/lua/plugins/lsp.lua
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
          -- Other lsp_signature options can be configured here
          -- zindex = 200, -- If it overlaps with other floating windows
          -- doc_lines = 0, -- No. of lines to display in doc, 0 to disable
        },
        event = "LspAttach", -- Load on LspAttach for optimization
      },
      "folke/which-key.nvim", -- For registering LSP keymaps
      "SmiteshP/nvim-navic",  -- For breadcrumbs in Lualine/statusline
      "hrsh7th/cmp-nvim-lsp", -- For nvim-cmp capabilities
    },
    config = function()
      local logger
      local core_debug_ok, core_debug = pcall(require, "core.debug")
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
          -- pathStrict = true, -- If you want stricter path checking for neodev
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
        -- Define basic fallbacks if icons are missing
        vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
        vim.fn.sign_define("DiagnosticSignWarn",  { text = "", texthl = "DiagnosticSignWarn" })
        vim.fn.sign_define("DiagnosticSignInfo",  { text = "", texthl = "DiagnosticSignInfo" })
        vim.fn.sign_define("DiagnosticSignHint",  { text = "", texthl = "DiagnosticSignHint" })
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
        dockerls = {}, docker_compose_language_service = {}, azure_pipelines_ls = {}, -- Renamed azurerm
        terraformls = { filetypes = {"terraform", "tf", "tfvars"} }, tflint = {}, helm_ls = {},
        yamlls = {
          settings = { yaml = { schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "**/docker-compose*.yml",
            ["kubernetes"] = "**/k8s/**/*.yml", -- Using Kubernetes schema from yamlls itself
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
        }}, javascript = { inlayHints = { -- Similar to typescript
          includeInlayParameterNameHints = "all", includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true, includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true, includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }}}},
        eslint = { settings = { workingDirectories = { { mode = "auto" } } } },
        denols = { init_options = { lint = true, unstable = true } },
        emmet_ls = {}, -- Renamed from emmet_language_server
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
          diagnostics = { globals = { "vim" } }, -- Add vim global for neovim lua dev
          hint = { enable = true, setType = true },
        }}},
        graphql = {}, prismals = {}, gopls = {
            settings = { gopls = {analyses = {unusedparams = true}, staticcheck = true }}
        },
        solidity_ls = {}, -- Renamed from solidity
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

      -- 5. Configure Mason-LSPConfig
      local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
      if mason_lspconfig_ok and mason_lspconfig then
        mason_lspconfig.setup({
          ensure_installed = vim.tbl_keys(servers),
          automatic_installation = true,
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
      -- Add inlay hint capability if supported by Neovim version
      if vim.lsp.protocol. আগে("3.17.0") then -- Check Neovim version for inlayHint support
        capabilities.textDocument.inlayHint = { dynamicRegistration = true }
        capabilities.workspace.inlayHint = { refreshSupport = true }
        logger.debug("Inlay hint capabilities added.")
      end
      logger.debug("LSP client capabilities configured.")

      -- 7. Define on_attach function
      local on_attach = function(client, bufnr)
        logger.info("LSP attached: " .. client.name .. " to buffer " .. bufnr)

        -- Enable nvim-navic for breadcrumbs
        if client.server_capabilities.documentSymbolProvider then
          local navic_ok, navic = pcall(require, "nvim-navic")
          if navic_ok and navic then
            navic.attach(client, bufnr)
            logger.debug("nvim-navic attached to " .. client.name)
          else
            logger.warn("nvim-navic not found or failed to load, cannot attach for breadcrumbs. Error: " .. tostring(navic))
          end
        end

        -- lsp_signature is configured via opts and event=LspAttach, no specific on_attach call needed here
        -- unless you want to override its default attach behavior.

        -- Buffer-local keymaps (optional, if not handled by global which-key mappings)
        -- Example: vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP Hover" })

        -- Optional: Format on save (can be noisy, consider a dedicated formatting plugin or manual formatting)
        -- if client.supports_method("textDocument/formatting") then
        --   local format_augroup = vim.api.nvim_create_augroup("LspFormatOnSave_" .. bufnr, { clear = true })
        --   vim.api.nvim_create_autocmd("BufWritePre", {
        --     group = format_augroup,
        --     buffer = bufnr,
        --     callback = function() vim.lsp.buf.format({ bufnr = bufnr, async = true, timeout_ms = 2000 }) end,
        --     desc = "Format file with LSP on save",
        --   })
        --   logger.debug("LSP formatting on save enabled for buffer " .. bufnr .. " with " .. client.name)
        -- end
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
            local server_user_opts = servers[server_name] or {} -- Get user-defined settings for this server
            local final_opts = vim.tbl_deep_extend("force", {
              capabilities = capabilities,
              on_attach = on_attach,
            }, server_user_opts) -- Merge defaults with user-specific settings

            lspconfig[server_name].setup(final_opts)
            logger.debug("LSP server '" .. server_name .. "' setup with final options.")
          end,
          -- Example of custom handler for a specific server if needed:
          -- ["lua_ls"] = function()
          --   lspconfig.lua_ls.setup({ ... custom lua_ls settings ... })
          -- end,
        })
      else
        logger.warn("mason-lspconfig not available. Manually setting up listed LSP servers.")
        -- Fallback to manual setup if mason-lspconfig failed (less ideal)
        for server_name, server_user_opts in pairs(servers) do
            local final_opts = vim.tbl_deep_extend("force", {
              capabilities = capabilities,
              on_attach = on_attach,
            }, server_user_opts or {})
            if lspconfig[server_name] then
                lspconfig[server_name].setup(final_opts)
                logger.debug("LSP server '" .. server_name .. "' (manual fallback) setup with final options.")
            else
                logger.warn("LSP config for server '" .. server_name .. "' not found in lspconfig module.")
            end
        end
      end

      -- 9. Register LSP keymaps with which-key
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok and wk then
        local lsp_keymaps_module_ok, lsp_keymaps_module = pcall(require, "keymaps.which-key.lsp")
        if lsp_keymaps_module_ok and lsp_keymaps_module and type(lsp_keymaps_module.register) == "function" then
          local keymap_logger = (core_debug_ok and core_debug.get_logger) and core_debug.get_logger("keymaps.which-key.lsp") or logger
          lsp_keymaps_module.register(wk, keymap_logger) -- Pass logger
          logger.info("LSP keymaps successfully registered with which-key.")
        else
          logger.warn("Failed to load or register LSP keymaps from 'keymaps.which-key.lsp'. Error or module structure issue: " .. tostring(lsp_keymaps_module))
        end
      else
        logger.warn("'which-key' module not available. LSP keymaps for which-key skipped. Error: " .. tostring(wk))
      end

      logger.info("nvim-lspconfig and its ecosystem configured successfully.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ 🛠️ Mason Tool Installer (Linters, Formatters, DAPs)     │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
    config = function()
      local logger_mti
      local core_debug_ok_mti, core_debug_mti = pcall(require, "core.debug")
      if core_debug_ok_mti and core_debug_mti and core_debug_mti.get_logger then
        logger_mti = core_debug_mti.get_logger("plugins.mason-tool-installer")
      else
        logger_mti = { info = function(m) print("INFO [MTI_P_FB]: " .. m) end, error = function(m) print("ERROR [MTI_P_FB]: " .. m) end }
        logger_mti.error("core.debug.get_logger not found for mason-tool-installer.")
      end

      logger_mti.info("Configuring mason-tool-installer.nvim...")
      local mti_ok, mti = pcall(require, "mason-tool-installer")
      if not mti_ok then
        logger_mti.error("Failed to load 'mason-tool-installer' module. Setup aborted. Error: " .. tostring(mti))
        return
      end

      mti.setup({
        ensure_installed = { -- Your list of tools
          "eslint_d", -- Using eslint_d for better performance
          "shellcheck", "hadolint", "markdownlint-cli", -- markdownlint-cli instead of markdownlint
          "jsonlint", "yamllint", "actionlint",
          "pylint", "mypy", "ruff", -- Added ruff
          "golangci-lint",
          "prettierd", -- Using prettierd for better performance
          "stylua", "black", "isort", "shfmt", "gofumpt", "rustfmt",
          "terraform-ls", -- Ensure terraformls is here if used as LSP, or just terraform_fmt for formatter
          "tflint",
          -- DAP adapters
          "debugpy", "delve", "vscode-js-debug-adapter", -- Renamed from js-debug-adapter
        },
        auto_update = false, -- Set to true if you want auto-updates
        run_on_start = false, -- Recommended false to not block startup
      })
      logger_mti.info("mason-tool-installer.nvim configured.")
    end,
  },

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ ❗ Trouble (Diagnostics, References, etc. viewer)        │
  -- ╰──────────────────────────────────────────────────────────╯
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/which-key.nvim" },
    opts = { -- Configure trouble using opts for cleaner setup
        position = "bottom", height = 10, width = 50,
        icons = true,
        mode = "workspace_diagnostics",
        fold_open = "", -- Example icons
        fold_closed = "",
        group = true,
        padding = true,
        action_keys = {
            close = "q", cancel = "<esc>",
            refresh = "r",
            jump = { "<cr>", "<tab>" },
            open_split = { "<c-s>" }, open_vsplit = { "<c-v>" },
            open_tab = { "<c-t>" },
            jump_close = { "o" },
            toggle_mode = "m",
            toggle_preview = "P",
            hover = "K",
            preview = "p",
            close_folds = {"zM", "zm"}, open_folds = {"zR", "zr"},
            toggle_fold = {"zA", "za"},
            previous = "k", next = "j"
        },
        indent_lines = true,
        auto_open = false, auto_close = false, auto_preview = true,
        auto_fold = false, auto_jump = {"lsp_definitions"},
        signs = {
            error = icons_ok and icons_utils and icons_utils.diagnostics and icons_utils.diagnostics.Error or "",
            warning = icons_ok and icons_utils and icons_utils.diagnostics and icons_utils.diagnostics.Warn or "",
            hint = icons_ok and icons_utils and icons_utils.diagnostics and icons_utils.diagnostics.Hint or "",
            information = icons_ok and icons_utils and icons_utils.diagnostics and icons_utils.diagnostics.Info or "",
            other = "﫠"
        },
        use_diagnostic_signs = false -- Let Neovim's signs handle the gutter
    },
    config = function(_, opts_from_lazy)
      local logger_tr
      local core_debug_ok_tr, core_debug_tr = pcall(require, "core.debug")
      if core_debug_ok_tr and core_debug_tr and core_debug_tr.get_logger then
        logger_tr = core_debug_tr.get_logger("plugins.trouble")
      else
        logger_tr = { info = function(m) print("INFO [TroubleP_FB]: " .. m) end, error = function(m) print("ERROR [TroubleP_FB]: " .. m) end, warn = function(m) print("WARN [TroubleP_FB]: " .. m) end }
        logger_tr.error("core.debug.get_logger not found for trouble.nvim.")
      end

      logger_tr.info("Configuring folke/trouble.nvim...")
      local trouble_ok, trouble = pcall(require, "trouble")
      if not trouble_ok then
        logger_tr.error("Failed to load 'trouble' module. Setup aborted. Error: " .. tostring(trouble))
        return
      end

      trouble.setup(opts_from_lazy)
      logger_tr.info("trouble.nvim configured.")

      -- Register Trouble keymaps with which-key
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok and wk then
        local trouble_keymaps_module_ok, trouble_keymaps_module = pcall(require, "keymaps.which-key.trouble")
        if trouble_keymaps_module_ok and trouble_keymaps_module and type(trouble_keymaps_module.register) == "function" then
          local keymap_logger = (core_debug_ok_tr and core_debug_tr.get_logger) and core_debug_tr.get_logger("keymaps.which-key.trouble") or logger_tr
          trouble_keymaps_module.register(wk, keymap_logger) -- Pass logger
          logger_tr.info("Trouble keymaps registered with which-key.")
        else
          logger_tr.warn("Failed to load or register Trouble keymaps from 'keymaps.which-key.trouble'. Error or module structure issue: " .. tostring(trouble_keymaps_module))
        end
      else
        logger_tr.warn("'which-key' module not available. Trouble keymaps for which-key skipped. Error: " .. tostring(wk))
      end
    end,
  },
}

