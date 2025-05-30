local M = {}
local sql = require("sqlite")

local db_path = vim.fn.stdpath("cache").."/debug_history.db"
local conn = sql.open(db_path)

-- Cria tabela se não existir
conn:exec[[
  CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    level TEXT,
    message TEXT,
    metadata TEXT
  )
]]

function M.log(level, msg, meta)
  conn:exec("INSERT INTO logs (level, message, metadata) VALUES (?, ?, ?)", {
    level,
    msg,
    vim.json.encode(meta or {})
  })
end

function M.query_last_hours(hours)
  return conn:exec("SELECT * FROM logs WHERE timestamp > datetime('now', ?)", {
    "-"..hours.." hours"
  })
end

vim.api.nvim_create_user_command("DebugHistory", function(opts)
  local hours = tonumber(opts.args) or 24
  local results = M.query_last_hours(hours)

  -- Exibe em um buffer temporário
  vim.cmd.new()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    "Histórico de Debug (Últimas "..hours.." horas):",
    unpack(vim.tbl_map(function(row)
      return string.format("[%s] %s: %s", row.timestamp, row.level, row.message)
    end, results))
  })
end, { nargs = "?", desc = "Mostra histórico de debug" })

return M

