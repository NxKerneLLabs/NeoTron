-- nvim/lua/plugins/cmp.lua
-- Plugin specifications for nvim-cmp, snippets, and AI assistants.

local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("plugins.cmp")) or fallback
  return {
    info  = function(m) print("INFO ["..name.."]: "..m) end,
    warn  = function(m) print("WARN ["..name.."]: "..m) end,
    error = function(m) print("ERROR ["..name.."]: "..m) end,
    debug = function(m) print("DEBUG ["..name.."]: "..m) end,
  }
end

return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "zbirenbaum/copilot-cmp",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build   = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          local logger
          local dbg_ok, dbg = pcall(require, "core.debug.logger") -- Caminho completo para o logger
          if dbg_ok and dbg and dbg.get_logger then
            logger = dbg.get_logger("plugins.luasnip")
          else
            logger = get_fallback_logger("LuaSnip")
            logger.error("core.debug.logger não encontrado. Usando fallback para LuaSnip.")
          end

          logger.info("Configuring LuaSnip…")
          local ls_ok, luasnip = pcall(require, "luasnip")
          if not ls_ok or not luasnip then
            logger.error("Failed to load 'luasnip'. Snippet setup aborted. Error: " .. tostring(luasnip))
            return
          end

          local loader_ok, loader = pcall(require, "luasnip.loaders.from_vscode")
          if loader_ok and loader then
            loader.lazy_load()
            -- Carrega snippets da tua pasta de configuração pessoal também
            loader.lazy_load({ paths = { vim.fn.stdpath("config").."/snippets" } })
            logger.info("LuaSnip snippets loaded.")
          else
            logger.warn("VSCode snippet loader not found: "..tostring(loader))
          end
        end,
      },
    },

    config = function()
      local logger
      -- Corrigido: Usar core.debug.logger para consistência
      local dbg_ok, dbg = pcall(require, "core.debug.logger")
      if dbg_ok and dbg and dbg.get_logger then
        logger = dbg.get_logger("plugins.cmp.config")
      else
        logger = get_fallback_logger("CMP_FB")
        logger.error("core.debug.logger não encontrado. Usando fallback para nvim-cmp.")
      end

      logger.info("Configuring nvim-cmp…")
      local cmp_ok, cmp = pcall(require, "cmp")
      if not cmp_ok or not cmp then
        logger.error("Failed to load 'cmp': "..tostring(cmp))
        return
      end

      local ls_ok, luasnip = pcall(require, "luasnip")
      if not ls_ok then logger.warn("'luasnip' not found: "..tostring(luasnip)) end

      local lspkind_ok, lspkind = pcall(require, "lspkind")
      if not lspkind_ok then logger.warn("'lspkind' not found: "..tostring(lspkind)) end

      -- copilot_cmp é uma dependência, mas a sua configuração é feita no plugin do Copilot
      -- Apenas verificamos se está disponível para a fonte.
      local cp_ok, _ = pcall(require, "copilot_cmp") -- Não precisamos da variável copilot_cmp aqui
      if not cp_ok then logger.warn("'copilot_cmp' source might not be available if Copilot plugin is not configured to use it.") end

      local function check_backspace()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
      end

      local sources = cmp.config.sources({
        { name = "copilot",  group_index = 1, priority = 100, keyword_length = 1, max_item_count = 3 },
        { name = "nvim_lsp", group_index = 2, priority = 90 },
        { name = "luasnip",  group_index = 2, priority = 80, keyword_length = 2 },
        { name = "buffer",   group_index = 3, priority = 70, keyword_length = 3 },
        { name = "path",     group_index = 3, priority = 60 },
      })

      local formatter
      if lspkind_ok and lspkind and lspkind.cmp_format then
        formatter = lspkind.cmp_format({
          mode            = "symbol_text",
          maxwidth        = 50,
          ellipsis_char   = "...",
          show_labelDetails = true,
          menu = {
            buffer   = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip  = "[Snippet]",
            path     = "[Path]",
            cmdline  = "[Cmd]",
            copilot  = "[Copilot]",
          },
        })
      else
        formatter = function(entry, vim_item)
          vim_item.kind = (vim_item.kind or "?") .. " " .. entry.source.name
          return vim_item
        end
        logger.warn("lspkind.cmp_format not available. Using basic formatter.")
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            if ls_ok and luasnip then
              luasnip.lsp_expand(args.body)
            else
              logger.warn("LuaSnip unavailable for snippet expansion.")
            end
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            elseif ls_ok and luasnip and luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            elseif ls_ok and luasnip and luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        formatting = { format = formatter },
        sources = sources,
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        experimental = { ghost_text = true },
      })

      cmp.setup.cmdline(":", { mapping = cmp.mapping.preset.cmdline(), sources = cmp.config.sources({ { name = "cmdline" } }, { { name = "path" } }) })
      cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })

      logger.info("nvim-cmp configured successfully.")
    end,
  },
}

