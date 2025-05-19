-- nvim/lua/plugins/cmp.lua
local M = {}

-- Sistema de logging robusto
local logger
do
  local ok, dbg = pcall(require, "core.debug.logger")
  if ok and dbg and dbg.get_logger then
    logger = dbg.get_logger("plugins.cmp")
  else
    logger = {
      info = function(m) print("[CMP] INFO: "..m) end,
      warn = function(m) print("[CMP] WARN: "..m) end,
      error = function(m) print("[CMP] ERROR: "..m) end,
      debug = function(m) print("[CMP] DEBUG: "..m) end
    }
    logger.warn("core.debug.logger não encontrado. Usando fallback.")
  end
end

-- Configuração do LuaSnip
local function setup_luasnip()
  local ok, luasnip = pcall(require, "luasnip")
  if not ok then
    logger.error("LuaSnip não carregado: "..tostring(luasnip))
    return nil
  end

  local loader_ok, loader = pcall(require, "luasnip.loaders.from_vscode")
  if loader_ok then
    loader.lazy_load()
    loader.lazy_load({ paths = { vim.fn.stdpath("config").."/snippets" } })
    logger.info("Snippets carregados")
  else
    logger.warn("Loader de snippets não encontrado")
  end

  return luasnip
end

-- Configuração principal do cmp
function M.setup()
  local cmp_ok, cmp = pcall(require, "cmp")
  if not cmp_ok then
    logger.error("Falha ao carregar nvim-cmp: "..tostring(cmp))
    return
  end

  local luasnip = setup_luasnip()
  local lspkind_ok, lspkind = pcall(require, "lspkind")
  local copilot_ok = pcall(require, "copilot_cmp")

  -- Configuração de formatação
  local format
  if lspkind_ok then
    format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      menu = {
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        path = "[Path]",
        copilot = "[AI]"
      }
    })
  else
    format = function(entry, item)
      item.menu = "[" .. entry.source.name .. "]"
      return item
    end
    logger.warn("lspkind não disponível - usando formatação simples")
  end

  -- Fontes de completamento
  local sources = {
    { name = "copilot", group_index = 1 },
    { name = "nvim_lsp", group_index = 2 },
    { name = "luasnip", group_index = 2 },
    { name = "buffer", group_index = 3 },
    { name = "path", group_index = 3 }
  }

  -- Mapeamentos
  local mappings = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  })

  -- Configuração principal
  cmp.setup({
    snippet = {
      expand = function(args)
        if luasnip then
          luasnip.lsp_expand(args.body)
        else
          logger.warn("Tentativa de expandir snippet sem LuaSnip")
        end
      end,
    },
    mapping = mappings,
    formatting = { format = format },
    sources = cmp.config.sources(sources),
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    experimental = { ghost_text = true }
  })

  -- Configuração para linha de comando
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "cmdline" },
      { name = "path" }
    })
  })

  logger.info("nvim-cmp configurado com sucesso")
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
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          setup_luasnip()
        end
      }
    },
    config = M.setup
  }
}

