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
        filetypes = {},
      },
    })

    logger.info("which-key configurado com sucesso.")
  end,
}

