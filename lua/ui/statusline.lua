local fallback = require("core.debug.fallback")
local ok_dbg, dbg = pcall(require, "core.debug.logger")
local logger = (ok_dbg and dbg.get_logger and dbg.get_logger("ui.statusline")) or fallback

require("lualine").setup({
  sections = {
    lualine_x = {
      function()
        local buf = dbg.get_buffer and dbg.get_buffer() or {}
        local last = bufg[#buf] or ""
        return last:match("%[(%u+)%]") or ""
      end
    }
  }
})
