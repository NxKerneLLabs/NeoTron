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
      replace = {
      key_labels = {
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
      show_help = true,
      show_keys = true,
      triggers = { " " }, -- Fixed: Proper table syntax
      disable = { -- Moved: Correct placement
        buftypes = {},
        filetypes = {},
      },
    }) -- End wk.setup
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
    logger.info("which-key configurado com sucesso.")
  end,
} -- End return plugin spec
