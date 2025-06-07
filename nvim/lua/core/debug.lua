-- ~/.config/nvim/lua/core/debug.lua
local M = {}

function M.get_logger(logger_name)
  local name = logger_name or "default"
  local function format_message(level, message_content)
    return string.format("[%s] %s: %s", name, level, tostring(message_content))
  end

  return {
    info = function(message)
      local formatted_msg = format_message("INFO", message)
      print(formatted_msg)
      -- return formatted_msg -- Se você quisesse que a função retornasse a string
    end,
    warn = function(message)
      local formatted_msg = format_message("WARN", message)
      print(formatted_msg)
      -- return formatted_msg
    end,
    error = function(message)
      local formatted_msg = format_message("ERROR", message)
      print(formatted_msg)
      -- return formatted_msg
    end,
    debug = function(message)
      local formatted_msg = format_message("DEBUG", message)
      print(formatted_msg)
      -- return formatted_msg
    end,
  }
end

return M
