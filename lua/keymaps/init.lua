-- keymaps/init.lua
-- Orquestrador central de mapeamentos para which-key

local function safe_require(mod)
  local ok, res = pcall(require, mod)
  return ok and res or nil
end

-- Logger robusto
local dbg_mod = safe_require("core.debug.logger")
local logger = dbg_mod and type(dbg_mod.get_logger)=="function"
  and dbg_mod.get_logger("keymaps")
  or {
    info    = function(m) print("ℹ️  [keymaps] "..m) end,
    warn    = function(m) print("⚠️  [keymaps] "..m) end,
    error   = function(m) print("❌ [keymaps] "..m) end,
    debug   = function(m) print("🐞 [keymaps] "..m) end,
    success = function(m) print("✔️  [keymaps] "..m) end,
  }

-- Ícones globais
local icons = safe_require("utils.icons") or {}
local ui_ic = icons.ui or {}

-- Nomes dos grupos por prefixo (Which-Key)
local prefix_groups = {
  [""]              = (ui_ic.Keyboard or "⌨")    .. " Main Actions",
  ["<leader>b"]     = (ui_ic.Tab or "󰓩")         .. " Buffers",
  ["<leader>c"]     = (icons.misc and icons.misc.Copilot or "") .. " Code/AI",
  ["<leader>d"]     = (icons.diagnostics and icons.diagnostics.Bug or "") .. " Debug/Diagnostics",
  ["<leader>e"]     = (ui_ic.FolderOpen or "") .. " Explorer",
  ["<leader>f"]     = (ui_ic.Search or "")     .. " Find/Files",
  ["<leader>g"]     = (icons.git and icons.git.Repo or "") .. " Git",
  ["<leader>l"]     = (icons.misc and icons.misc.LSP or "") .. " LSP",
  ["<leader>t"]     = (ui_ic.Terminal or "")    .. " Terminal",
  ["<leader>x"]     = (icons.diagnostics and icons.diagnostics.Warn or "") .. " Trouble/Extra",
  ["<leader>q"]     = (ui_ic.Exit or "")       .. " Quit/Session",
}

-- Inicializa Which-Key
local wk = safe_require("which-key")
if not wk then
  logger.error("which-key não encontrado. Abortando orquestrador.")
  return
end

-- Registra os nomes dos grupos
wk.register(vim.tbl_map(function(pref)
  return { pref, group = prefix_groups[pref] }
end, vim.tbl_keys(prefix_groups)))
logger.debug("Grupos de prefixos registrados.")

-- Carrega módulos
local modules = safe_require("keymaps.modules")
if type(modules) ~= "table" then
  logger.error("keymaps.modules inválido.")
  return
end

-- Ordena para garantir consistência
pcall(function() table.sort(modules, function(a,b) return a.path < b.path end) end)

-- Aplica os mapeamentos de cada módulo
for _, mod_info in ipairs(modules) do
  local path = mod_info.path
  local prefix = mod_info.prefix or ""
  logger.debug(string.format("Processando módulo: %s com prefixo '%s'", path, prefix))
  local ok, m = pcall(require, path)
  if not ok then
    logger.warn("Falha ao carregar: " .. path)
  elseif type(m.get_mappings) ~= "function" then
    logger.warn("get_mappings ausente em: " .. path)
  else
    local maps = m.get_mappings(icons, logger)
    if type(maps) == "table" and next(maps) then
      wk.register(maps, { prefix = prefix, name = prefix_groups[prefix] })
      logger.success("Registrado: " .. path)
    else
      logger.debug("Nenhum mapeamento retornado em: " .. path)
    end
  end
end
logger.info("✔️  Orquestrador Which-Key finalizado com sucesso.") 
