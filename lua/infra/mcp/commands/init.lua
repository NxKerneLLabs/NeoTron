-- Integração com which-key para registrar comandos MCP
local Commands = {}

function Commands.setup()
  local wk_ok, wk = pcall(require, "which-key")
  if not wk_ok then
    vim.notify("which-key.nvim não encontrado", vim.log.levels.WARN)
    return
  end

  wk.register({
    m = {
      name = "MCP",
      o = { function() require("infra.mcp.screen").open_panel() end, "Abrir painel MCP" },
      a = { function() require("infra.mcp.agents").list_agents() end, "Listar agentes" },
      r = { function() -- Refatorar seleção
          local selection = table.concat(vim.fn.getline("'<", "'>"), "\n")
          local res = require("infra.mcp.agents").execute("refactor", selection)
          require("infra.mcp.screen").show_output(res or "Falha na refatoração")
        end, "Refatorar seleção" 
      },
      e = { function() -- Explicar seleção
          local code = table.concat(vim.fn.getline("'<", "'>"), "\n")
          local res = require("infra.mcp.agents").execute("explain", code)
          require("infra.mcp.screen").show_output(res or "Falha ao explicar")
        end, "Explicar seleção"
      },
      h = { function() -- Mostrar histórico
          local hist = require("infra.mcp.memory").get_history()
          require("infra.mcp.screen").show_output(table.concat(hist, "\n"))
        end, "Mostrar histórico MCP" 
      },
    },
  }, { prefix = "<leader>" })

  -- Comandos diretos (ex.: :MCPRunAutoRefactor)
  vim.api.nvim_create_user_command("MCPRunAutoRefactor", function()
    local file = vim.fn.expand("%:p")
    local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local res = require("infra.mcp.agents").execute("refactor", table.concat(content, "\n"))
    require("infra.mcp.screen").show_output(res or "Refactor falhou")
  end, { nargs = 0 })

end

return Commands

