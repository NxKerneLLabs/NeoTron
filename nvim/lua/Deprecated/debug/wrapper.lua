-- nvim/lua/core/debug/wrapper.lua
-- Tools for creating debug wrappers around functions with safe_require, namespace logging, and error resilience

-- Safe require util
local safe_require = require("core.debug.safe_require")

-- Logger setup with fallback
local logger_ok, logger_mod = safe_require("core.debug.logger")
local logger = (logger_ok and logger_mod.get_logger) and logger_mod.get_logger("core.debug.wrapper") or require("core.debug.fallback")

local M = {}

-- Wrapers de registro (e.g., which-key.register)
function M.wrap_register(original_func, namespace, func_name)
  return function(mappings, opts)
    logger.debug(namespace, "Tentando registrar mapeamentos com " .. func_name .. ": " .. vim.inspect(mappings))
    for i, mapping in ipairs(mappings or {}) do
      local lhs = mapping[1]
      if not lhs or lhs == "" then
        logger.error(namespace, "Mapeamento inválido (LHS vazio): Índice " .. i .. ", Detalhes: " .. vim.inspect(mapping))
      end
    end
    local ok, err = pcall(original_func, mappings, opts)
    if not ok then
      logger.error(namespace, "Erro ao registrar mapeamentos com " .. func_name .. ": " .. tostring(err) .. "\nMapeamentos: " .. vim.inspect(mappings))
    else
      logger.debug(namespace, "Mapeamentos registrados com sucesso usando " .. func_name .. ".")
    end
    return ok, err
  end
end

-- Wrapers gerais para funções críticas
function M.wrap_function(original_func, namespace, func_name)
  return function(...)
    local args = { ... }
    logger.debug(namespace, "Chamando " .. func_name .. " com args: " .. vim.inspect(args))
    local ok, result = pcall(original_func, ...)
    if not ok then
      logger.error(namespace, "Erro ao chamar " .. func_name .. ": " .. tostring(result))
      return nil, result
    end
    logger.debug(namespace, func_name .. " retornou: " .. vim.inspect(result))
    return result
  end
end

return M

