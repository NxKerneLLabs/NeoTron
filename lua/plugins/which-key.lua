-- plugins/which-key.lua
local logger = require("core.debug.logger") or nil

local function create_fallback_logger(prefix)
  return {
    info = function(msg) print("INFO [" .. prefix .. "]: " .. msg) end,
    warn = function(msg) print("WARN [" .. prefix .. "]: " .. msg) end,
    error = function(msg) print("ERROR [" .. prefix .. "]: " .. msg) end,
    debug = function(msg) print("DEBUG [" .. prefix .. "]: " .. msg) end,
  }
end

logger = logger or create_fallback_logger("plugins.which-key")

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
      replace = {
        ["<leader>"] = "󱁐",
      },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      keys = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      win = {
        border = "single",
        no_overlap = true,
        padding = {1, 0},
        title = true,
        title_pos = "center",
        zindex = 1000,
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      show_help = true,
      show_keys = true,
      triggers = { "" }, -- Fixed: Proper table syntax
      disable = { -- Moved: Correct placement
        buftypes = {},
        filetypes = {},
      },
    }) -- End wk.setup

    logger.info("which-key configurado com sucesso.")
  end,
} -- End return plugin spec
