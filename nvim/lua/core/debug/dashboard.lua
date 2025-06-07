local M = {}
local api = vim.api
local fn = vim.fn
local logger = require("core.debug.logger")
local log = logger.get_logger("DASHBOARD")

-- Configuração padrão
local config = {
  width = 0.8,  -- 80% da largura da tela
  height = 0.7, -- 70% da altura
  hotkeys = {
    close = "<Esc>",
    refresh = "R",
    apply_fix = "<CR>"
  }
}

-- Estado do dashboard
local state = {
  buf = nil,
  win = nil,
  last_update = 0
}

-- Dados em tempo real
local stats = {
  performance = {},
  errors = {},
  suggestions = {}
}

-- Função para coletar métricas do sistema
local function collect_stats()
  local new_stats = {
    memory = math.floor(collectgarbage("count") / 1000 .. " MB",
    plugins = #vim.fn.globpath(vim.fn.stdpath("data").."/lazy/*", 0, 1),
    lsp_clients = #vim.lsp.get_active_clients(),
    uptime = os.difftime(os.time(), vim.g.start_time) .. "s"
  }

  stats.performance = new_stats
end

-- Analisa os últimos logs para sugestões
local function analyze_logs()
  local errors = {}
  local suggestions = {}

  -- Padrões comuns de erro e suas soluções
  local patterns = {
    {
      match = "E492: Not an editor command",
      fix = "Verifique se o plugin está instalado",
      cmd = "Lazy sync"
    },
    {
      match = "module.*not found",
      fix = "Arquivo Lua ausente no runtimepath",
      cmd = "edit "..vim.fn.stdpath("config").."/lua/"
    }
  }

  -- Simples análise (podemos evoluir para IA depois)
  for _, pattern in ipairs(patterns) do
    if logger.search(pattern.match) then
      table.insert(errors, pattern.match)
      table.insert(suggestions, {
        text = pattern.fix,
        cmd = pattern.cmd
      })
    end
  end

  stats.errors = errors
  stats.suggestions = suggestions
end

-- Renderiza o conteúdo do dashboard
local function render_content()
  if not api.nvim_buf_is_valid(state.buf) then return end

  local lines = {}
  local highlights = {}

  -- Cabeçalho
  table.insert(lines, "⚡ NVIM DEBUG DASHBOARD")
  table.insert(highlights, {"DashboardHeader", 0, 0, #lines[1]})

  -- Seção de Performance
  table.insert(lines, "")
  table.insert(lines, "📊 PERFORMANCE")
  for k, v in pairs(stats.performance) do
    table.insert(lines, string.format("  %-12s: %s", k, v))
  end

  -- Seção de Erros
  table.insert(lines, "")
  table.insert(lines, "❗ ÚLTIMOS ERROS")
  if #stats.errors == 0 then
    table.insert(lines, "  Nenhum erro crítico detectado")
  else
    for i, err in ipairs(stats.errors) do
      table.insert(lines, string.format("  %d. %s", i, err:sub(1, 50)))
    end
  end

  -- Seção de Sugestões
  table.insert(lines, "")
  table.insert(lines, "💡 SUGESTÕES")
  if #stats.suggestions == 0 then
    table.insert(lines, "  Tudo parece estar funcionando bem!")
  else
    for i, sug in ipairs(stats.suggestions) do
      table.insert(lines, string.format("  %d. %s", i, sug.text))
      table.insert(highlights, {"DashboardSuggestion", #lines-1, 0, #lines[#lines]})
    end
  end

  -- Atualiza o buffer
  api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  -- Aplica syntax highlighting
  api.nvim_buf_clear_namespace(state.buf, -1, 0, -1)
  for _, hl in ipairs(highlights) do
    api.nvim_buf_add_highlight(state.buf, -1, hl[1], hl[2], hl[3], hl[4])
  end

  -- Mapeamentos locais
  local opts = {noremap = true, silent = true, buffer = state.buf}
  vim.keymap.set('n', config.hotkeys.close, function() M.close() end, opts)
  vim.keymap.set('n', config.hotkeys.refresh, function() M.update() end, opts)
end

-- Atualiza o dashboard
function M.update()
  collect_stats()
  analyze_logs()
  render_content()
  state.last_update = os.time()
end

-- Fecha o dashboard
function M.close()
  if api.nvim_win_is_valid(state.win) then
    api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

-- Abre o dashboard principal
function M.open()
  -- Fecha se já estiver aberto
  if state.win and api.nvim_win_is_valid(state.win) then
    M.close()
    return
  end

  -- Cria buffer e janela
  state.buf = api.nvim_create_buf(false, true)
  state.win = api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * config.width),
    height = math.floor(vim.o.lines * config.height),
    col = math.floor((vim.o.columns - (vim.o.columns * config.width)) / 2),
    row = math.floor((vim.o.lines - (vim.o.lines * config.height)) / 2),
    style = "minimal",
    border = "rounded"
  })

  -- Configurações do buffer
  api.nvim_buf_set_option(state.buf, 'filetype', 'dashboard')
  api.nvim_buf_set_option(state.buf, 'buftype', 'nofile')

  -- Atualiza conteúdo inicial
  M.update()

  -- Autocomandos para redimensionamento
  api.nvim_create_autocmd("VimResized", {
    callback = function()
      if api.nvim_win_is_valid(state.win) then
        api.nvim_win_set_config(state.win, {
          width = math.floor(vim.o.columns * config.width),
          height = math.floor(vim.o.lines * config.height),
          col = math.floor((vim.o.columns - (vim.o.columns * config.width)) / 2),
          row = math.floor((vim.o.lines - (vim.o.lines * config.height)) / 2)
        })
      end
    end,
    buffer = state.buf
  })

  log.info("Dashboard aberto")
end

-- Comando principal
api.nvim_create_user_command("DebugDashboard", M.open, {
  desc = "Abre o painel de diagnóstico avançado"
})

return M

