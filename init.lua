-- ~/.config/nvim/init.lua
-- Bootstrapping refatorado com carregamento dinâmico de módulos, logger com namespace e performance

-- Início da medição de performance
local startup_start = vim.loop.hrtime()

-- Variáveis globais
vim.g.python3_host_prog   = "/usr/bin/python3"
vim.g.selected_theme_name = "tokyonight_theme"
vim.g.mapleader           = " "
vim.g.maplocalleader      = "\\"
vim.g.editorconfig        = false
vim.g.log_namespace       = vim.env.NVIM_LOG_NS or "init"

-- Função helper para carregar módulos com pcall e notificar falhas
local function try(modname, fallback)
  local ok, mod = pcall(require, modname)
  if not ok then
    vim.notify(string.format("[%s] Falha ao carregar '%s': %s", vim.g.log_namespace, modname, tostring(mod)), vim.log.levels.ERROR)
    return fallback
  end
  return mod
end

-- Carrega módulo de configuração de debug
local config = try("core.debug.config", {
  silent_mode     = false,
  buffer_size     = 20,
  flush_interval  = 2000,
  performance_log = false,
})

-- Carrega módulos de debug/logger
local debug_mod  = try("core.debug", nil)
local logger_mod = try("core.debug.logger", nil)

-- Logger com namespace dinâmico
local logger = logger_mod and logger_mod.get_logger(vim.g.log_namespace) or {
  info  = function(_, m) vim.notify(string.format("[%s] INFO: %s", vim.g.log_namespace, m), vim.log.levels.INFO) end,
  error = function(_, m) vim.notify(string.format("[%s] ERRO: %s", vim.g.log_namespace, m), vim.log.levels.ERROR) end,
}

-- Wrapper para carregar e logar módulos com profiling opcional
local function load(name)
  local t0 = vim.loop.hrtime()
  local ok = try(name)
  local t1 = vim.loop.hrtime()
  if ok then
    logger:info(string.format("Módulo '%s' carregado.", name))
    if config.performance_log and logger_mod then
      local buf = logger_mod.get_buffer()
      buf[#buf + 1] = string.format("[PERF] [%s] load('%s') levou %.2fms\n", vim.g.log_namespace, name, (t1 - t0) / 1e6)
    end
  end
end

-- Carrega configurações core
load("core.options")
load("core.autocmds")

-- Carrega keymaps e utils
load("core.keymaps.init")
require("utils.forensic").disable()

-- Inicializa plugin manager (lazy.nvim)
local lazy = try("plugins.lazy", nil)
if not lazy then return end
logger:info("lazy.nvim inicializado.")

-- Performance otimizada para lazy.nvim
lazy.setup({
  performance = config.performance_log and { rtp = { disabled_plugins = {} } } or nil,
  defaults    = { lazy = true },
})

-- Carrega specs de plugins adicionais
load("plugins.which-key")
load("plugins.which-key-lsp")

-- Integração do Explorer (nvim-tree)
load("plugins.nvimtree")
vim.keymap.set("n", "<leader>e", function() require("nvim-tree.api").tree.toggle() end, { desc = "Toggle Explorer" })

-- Integração de Git e extensões de terceiros
load("plugins.git")
load("plugins.gitsigns")
load("plugins.fugitive")
local wk = require("which-key")
wk.register({
  g = {
    name = "Git",
    s = { function() require("gitsigns").stage_hunk() end, "Stage Hunk" },
    u = { function() require("gitsigns").undo_stage_hunk() end, "Undo Stage Hunk" },
    p = { function() require("gitsigns").preview_hunk() end, "Preview Hunk" },
    b = { function() require("gitsigns").blame_line({ full = true }) end, "Blame Line" },
    d = { function() require("gitsigns").diffthis() end, "Diff This" },
    D = { function() require("gitsigns").diffthis('~') end, "Diff Against HEAD" },
    g = { ":Git<CR>", "Open Fugitive" },
  },
}, { prefix = "<leader>" })

-- Integração Avançada Telescope
load("plugins.telescope")
require("telescope").setup({
  defaults = {
    vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case"
    },
    prompt_prefix = "🔍 ",
    selection_caret = "➤ ",
    path_display = { "smart" },
    file_ignore_patterns = { "node_modules", ".git/" },
  },
  pickers = {
    find_files = { theme = "dropdown" },
    live_grep = { theme = "ivy" },
  },
  extensions = {
    fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
    projects = {},
  },
})
pcall(function() require("telescope").load_extension("fzf") end)
pcall(function() require("telescope").load_extension("projects") end)
wk.register({
  t = {
    name = "Telescope",
    f = { function() require("telescope.builtin").find_files() end, "Files" },
    g = { function() require("telescope.builtin").live_grep() end, "Live Grep" },
    b = { function() require("telescope.builtin").buffers() end, "Buffers" },
    h = { function() require("telescope.builtin").help_tags() end, "Help Tags" },
    p = { function() require("telescope").extensions.projects.projects() end, "Projects" },
  },
}, { prefix = "<leader>" })

-- Integração Dashboard Avançado
load("plugins.dashboard")
require("ui.dashboard").setup({
  theme = vim.g.selected_theme_name,
  config = {
    header = "Neovim IDE",
    buttons = {
      { "e", "  New File", "<cmd>ene!<CR>" },
      { "f", "  Find File", "<cmd>Telescope find_files<CR>" },
      { "p", "  Projects", "<cmd>Telescope projects<CR>" },
      { "r", "  Recent Files", "<cmd>Telescope oldfiles<CR>" },
      { "g", "  Grep Text", "<cmd>Telescope live_grep<CR>" },
      { "c", "  Settings", "<cmd>e ~/.config/nvim/init.lua<CR>" },
      { "q", "  Quit", "<cmd>qa<CR>" },
    },
  },
})
vim.keymap.set("n", "<leader>d", function() require("ui.dashboard").open() end, { desc = "Open Dashboard" })

-- Integração Treesitter para melhor syntax
load("plugins.treesitter")
require("nvim-treesitter.configs").setup({ ensure_installed = { "lua", "python", "javascript", "typescript", "html", "css" }, highlight = { enable = true }, indent = { enable = true }, rainbow = { enable = true, extended_mode = true } })

-- Configuração de LSP Servers
load("plugins.lsp")
local lspconfig = require("lspconfig")
for _, srv in ipairs({ "pyright", "tsserver", "html", "cssls", "lua_ls" }) do
  lspconfig[srv].setup({
    on_attach = function(client, bufnr)
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
      vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, bufopts)
    end,
  })
end

-- Integração de agentes AI inline com controle avançado e suporte Azure
local agent_conf = try("core.agents.config", {
  provider             = vim.env.AI_PROVIDER or "openai",
  endpoint             = vim.env.AZURE_OPENAI_ENDPOINT or vim.env.OPENAI_API_BASE or nil,
  api_key              = vim.env.AZURE_OPENAI_KEY or vim.env.OPENAI_API_KEY or nil,
  deployment           = vim.env.AZURE_OPENAI_DEPLOYMENT_ID or nil,
  model                = vim.env.AI_MODEL or "gpt-4",
  temperature          = tonumber(vim.env.AI_TEMPERATURE or "0.7"),
  max_tokens           = tonumber(vim.env.AI_MAX_TOKENS or "1024"),
  top_p                = tonumber(vim.env.AI_TOP_P or "1.0"),
  frequency_penalty    = tonumber(vim.env.AI_FREQ_PENALTY or "0"),
  presence_penalty     = tonumber(vim.env.AI_PRES_PENALTY or "0"),
  top_k                = tonumber(vim.env.AI_TOP_K or "5"),
  stream               = vim.env.AI_STREAM == "1",
  timeout              = tonumber(vim.env.AI_TIMEOUT or "30000"),
  inline_menu          = true,
  system_prompt        = vim.env.AI_SYSTEM_PROMPT or "Você é um assistente de programação habilidoso e conciso.",
  post_instructions    = vim.env.AI_POST_INSTRUCTIONS or "Use somente funções definidas no buffer.",
})
load("plugins.agents")
require("agents").setup(agent_conf)
wk.register({
  a = {
    name = "AI",
    c = { function() require("agents").chat_buffer({ system = agent_conf.system_prompt }) end, "Chat Buffer" },
    s = { function() require("agents").select_and_chat({ system = agent_conf.system_prompt }) end, "Seleção -> Chat" },
    e = { function() require("agents").explain_line({ system = agent_conf.system_prompt }) end, "Explicar Linha" },
    r = { function() require("agents").refactor_selection({ system = agent_conf.system_prompt }) end, "Refatorar Seleção" },
    p = { function() require("agents").prompt_input({ system = agent_conf.system_prompt }) end, "Prompt Manual" },
  },
}, { prefix = "<leader>" })

-- Gerenciamento de janelas (winshift + splits + pick)
load("plugins.window_picker")
pcall(function() require("winshift").setup({ highlight_moving_win = true, focused_hl_group = "Visual" }) end)
wk.register({ w = {
    name = "Janela",
    s = { ":split<CR>", "Split Horizontal" },
    v = { ":vsplit<CR>", "Split Vertical" },
    m = { function() require("winshift").start_move() end, "Mover Janela" },
    p = { function() require("window-picker").pick_window() end, "Escolher Janela" },
    ["="] = { ":vertical resize +5<CR>", "Aumentar Largura" },
    ["-"] = { ":vertical resize -5<CR>", "Diminuir Largura" },
  }, }, { prefix = "<leader>" })

-- Sinaliza fim do carregamento
if debug_mod then debug_mod:info("Configuração Neovim totalmente carregada.") end
logger:info("Startup completo.")

-- Medição de performance de startup
local startup_end = vim.loop.hrtime()
local elapsed_ms = (startup_end - startup_start) / 1e6
if config.performance_log and logger_mod then
  local buf = logger_mod.get_buffer()
  buf[#buf + 1] = string.format("[PERF] [%s] Startup completed in %.2fms\n", vim.g.log_namespace, elapsed_ms)
end

