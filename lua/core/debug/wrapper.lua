-- nvim/lua/core/debug/wrapper.lua
-- Tools for creating debug wrappers around functions

local logger = require("core.debug.logger")

local M = {}

function M.wrap_register(original_func, namespace, func_name)
  return function(mappings, opts)
    logger.debug(namespace, "Tentando registrar mapeamentos com " .. func_name .. ": " .. vim.inspect(mappings))
    for i, mapping in ipairs(mappings) do
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
    return ok
  end
end

function M.wrap_function(original_func, namespace, func_name)
  return function(...)
    local args = { ... }
    logger.debug(namespace, "Chamando " .. func_name .. " com args: " .. vim.inspect(args))
    local ok, result = pcall(original_func, ...)
    if not ok then
      logger.error(namespace, "Erro ao chamar " .. func_name .. ": " .. tostring(result))
      return nil
    end
    logger.debug(namespace, func_name .. " retornou: " .. vim.inspect(result))
    return result
  end
end

return M
