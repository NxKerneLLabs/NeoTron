-- lua/core/autocmds.lua
-- Comandos automáticos para eventos no Neovim

local logger_ok, debug = pcall(require, "core.debug.logger")
local debug_log = (logger_ok and debug.get_logger) and debug.get_logger("autocmds") or {
  info = function(m) print("ℹ️  [autocmds] " .. m) end,
  warn = function(m) print("⚠️  [autocmds] " .. m) end,
  error = function(m) print("❌ [autocmds] " .. m) end,
  debug = function(m) print("🐞 [autocmds] " .. m) end,
}

autocmd = vim.api.nvim_create_autocmd
augroup = vim.api.nvim_create_augroup
local CustomGroup = augroup("CustomUserAutocmds", { clear = true })

-- Comando para diagnóstico de módulos de keymaps
vim.api.nvim_create_user_command("CheckKeymapsModules", function()
  local path = vim.fn.stdpath("config") .. "/lua/scripts/check_keymap_modules.lua"
  local ok, err = pcall(dofile, path)
  if not ok then
    debug_log.error("Erro ao rodar CheckKeymapsModules: " .. tostring(err))
  end
end, { desc = "🔍 Verificar módulos de keymaps" })

-- Trailing whitespace removal
autocmd("BufWritePre", {
  group = CustomGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
  desc = "Remove trailing whitespace on save",
})

-- Return cursor to last position
autocmd("BufReadPost", {
  group = CustomGroup,
  pattern = "*",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Return to last cursor position on opening a file",
})

-- Highlight yank
autocmd("TextYankPost", {
  group = CustomGroup,
  pattern = "*",
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 }) end,
  desc = "Highlight yanked text briefly",
})

-- Relative number toggle
local function set_relative_number(enable)
  if vim.wo.number then vim.wo.relativenumber = enable end
end
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = CustomGroup,
  pattern = "*",
  callback = function() set_relative_number(true) end,
  desc = "Enable relative numbers in normal mode / focused window",
})
autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = CustomGroup,
  pattern = "*",
  callback = function() set_relative_number(false) end,
  desc = "Disable relative numbers in insert mode / unfocused window",
})

-- Ensure undo directory exists
local fn = vim.fn
local undodir_path = fn.stdpath("data") .. "/undo"
autocmd("VimEnter", {
  group = CustomGroup,
  pattern = "*",
  callback = function()
    if fn.isdirectory(undodir_path) ~= 1 then
      pcall(fn.mkdir, undodir_path, "p", "0700")
      debug_log.info("Diretório de undo criado em: " .. undodir_path)
    end
  end,
  desc = "Ensure undo directory exists on startup",
})

-- Handle colorscheme changes
autocmd("ColorScheme", {
  group = CustomGroup,
  pattern = "*",
  callback = function()
    local theme = vim.g.colors_name or "unknown"
    debug_log.info("Colorscheme mudou para: " .. theme)
  end,
  desc = "Handle UI updates on colorscheme change",
})

debug_log.info("Comandos automáticos (lua/core/autocmds.lua) carregados e configurados!")

