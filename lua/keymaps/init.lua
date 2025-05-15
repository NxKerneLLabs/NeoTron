-- keymaps/init.lua

-- Logger
local ok_dbg, dbg_mod = pcall(require, "core.debug.logger")
local logger = ok_dbg and type(dbg_mod.get_logger) == "function"
  and dbg_mod.get_logger("keymaps")
  or {
    info  = function(m) print("ℹ️  [keymaps] " .. m) end,
    warn  = function(m) print("⚠️  [keymaps] " .. m) end,
    error = function(m) print("❌ [keymaps] " .. m) end,
    debug = function(m) print("🐞 [keymaps] " .. m) end,
  }

-- Comando e keymap para diagnóstico (sem require direto)
vim.api.nvim_create_user_command("KeymapDoctor", function()
  local path = vim.fn.stdpath("config") .. "/lua/scripts/check_keymap_modules.lua"
  local ok, err = pcall(dofile, path)
  if not ok then
    logger.error("Erro ao rodar KeymapDoctor: " .. tostring(err))
  end
end, { desc = "🔍 Diagnóstico dos módulos de keymaps" })

vim.keymap.set("n", "<leader>K", "<cmd>KeymapDoctor<cr>",
  { desc = "🔍 Verificar módulos de keymaps" }
)

-- which-key
local ok_wk, which_key = pcall(require, "which-key")
if not ok_wk then
  logger.error("which-key não pôde ser carregado.")
  return
end

-- Lista de módulos
local ok_list, modules = pcall(require, "keymaps.module_list")
if not ok_list or type(modules) ~= "table" then
  logger.error("Não foi possível carregar keymaps.module_list.")
  return
end

-- Registra cada módulo
for _, module in ipairs(modules) do
  if type(module) ~= "table" or type(module.path) ~= "string" then
    logger.warn("Entrada inválida em module_list: " .. vim.inspect(module))
  else
    local ok_mod, mod = pcall(require, module.path)
    if not ok_mod then
      logger.warn("Erro ao carregar " .. module.path .. ": " .. tostring(mod))
    elseif type(mod.get_mappings) ~= "function" then
      logger.warn("Módulo " .. module.path .. " não implementa get_mappings()")
    else
      local mappings = mod.get_mappings()
      -- Garante descrições
      for lhs, map in pairs(mappings) do
        if type(map) == "table" and not map.desc then
          map.desc = "🔧 Sem descrição"
          logger.warn("Mapping sem desc: " .. lhs)
        end
      end
      which_key.register(mappings, { prefix = module.prefix or "<leader>" })
      logger.info("✅ Registrado: " .. module.path)
    end
  end
end
