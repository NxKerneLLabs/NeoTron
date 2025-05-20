-- Caminho: lua/keymaps/definitions/git.lua

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/Git] Gerando mapeamentos para Git...")

  local git_fns_ok, git_fns = pcall(require, "functions.git")
  if not git_fns_ok then
    logger.warn("[Defs/Git] 'functions.git' não encontrado. Funções específicas podem não funcionar. Erro: " .. tostring(git_fns))
    git_fns = {}
  end

  local git_icons = icons.git or {}
  local misc_icons = icons.misc or {}

  -- Ícones padrão unificados
  local icons_map = {
    repo    = git_icons.Repo or "",
    branch  = git_icons.Branch or "",
    commit  = git_icons.Commit or "",
    diff    = git_icons.Diff or "",
    add     = git_icons.GitSignsAdd or "",
    change  = git_icons.GitSignsChange or "",
    delete  = git_icons.GitSignsDelete or "",
    stash   = git_icons.Stash or "󰚫",
    list    = misc_icons.List or "",
    staged  = git_icons.Staged or "✓",
    unstaged = git_icons.Unstaged or "✗",
  }

  -- Função unificada para chamadas seguras de funções Git
  local function safe_fn(fn_name, desc)
    if type(git_fns[fn_name]) == "function" then
      return git_fns[fn_name]
    else
      return function()
        logger.warn("[Defs/Git] Função Git '" .. fn_name .. "' não disponível. Ação: " .. desc)
      end
    end
  end

  -- Mapeamentos sob <leader>g, integrando ambas as versões
  local mappings = {
    ["<leader>g"] = {
      name = icons_map.repo .. " Git Actions",
      -- Hunk actions
      s = { safe_fn("stage_hunk", "Stage Hunk"), desc = icons_map.staged .. " Stage Hunk" },
      r = { safe_fn("reset_hunk", "Reset Hunk"), desc = icons_map.unstaged .. " Reset Hunk" },
      u = { safe_fn("undo_stage_hunk", "Undo Stage Hunk"), desc = icons_map.stash .. " Undo Stage Hunk" },
      p = { safe_fn("preview_hunk", "Preview Hunk"), desc = icons_map.diff .. " Preview Hunk" },
      b = { safe_fn("toggle_blame_line", "Toggle Blame Line"), desc = icons_map.commit .. " Toggle Blame Line" },
      B = { safe_fn("toggle_line_blame", "Toggle Blame"), desc = icons_map.commit .. " Toggle Blame" },
      H = { safe_fn("select_hunk", "Select Hunk"), desc = icons_map.list .. " Select Hunk" },
      -- Buffer hunk actions
      S = { safe_fn("stage_buffer", "Stage Buffer"), desc = icons_map.staged .. " Stage Buffer" },
      R = { safe_fn("reset_buffer", "Reset Buffer"), desc = icons_map.unstaged .. " Reset Buffer" },
      -- Diffview
      d = { safe_fn("diff_this", "Diff This (HEAD)"), desc = icons_map.diff .. " Diff This (HEAD)" },
      D = { safe_fn("diff_this_prev", "Diff This (~)"), desc = icons_map.diff .. " Diff This (~)" },
      o = { safe_fn("diffview_open", "Open Diffview"), desc = icons_map.diff .. " Diffview Open" },
      c = { safe_fn("diffview_close", "Close Diffview"), desc = icons_map.diff .. " Diffview Close" },
      h = { safe_fn("diffview_file_history", "File History"), desc = icons_map.diff .. " File History" },
      -- Prefixo 'v' para Diffview (da segunda versão)
      v = {
        name = icons_map.diff .. " Diffview",
        o = { safe_fn("diffview_open", "Diffview Open"), desc = icons_map.diff .. " Diffview Open" },
        c = { safe_fn("diffview_close", "Diffview Close"), desc = icons_map.diff .. " Diffview Close" },
        h = { safe_fn("diffview_file_history", "Diffview File History"), desc = icons_map.diff .. " Diffview File History" },
      },
      -- Fugitive
      g = { "<cmd>Git<cr>", desc = icons_map.branch .. " Fugitive Status" },
      P = { "<cmd>Git push<cr>", desc = icons_map.branch .. " Git Push" },
      L = { "<cmd>Git pull<cr>", desc = icons_map.branch .. " Git Pull" },
      f = { "<cmd>Git blame<cr>", desc = icons_map.commit .. " Git Blame (Fugitive)" },
      C = { "<cmd>Git commit --amend<cr>", desc = icons_map.commit .. " Amend Commit" },
      -- Branching
      n = { safe_fn("create_branch", "New Branch"), desc = icons_map.branch .. " New Branch" },
      m = { safe_fn("move_branch", "Move/Rename Branch"), desc = icons_map.branch .. " Move Branch" },
      -- Misc
      t = { safe_fn("toggle_deleted", "Toggle Deleted"), desc = icons_map.delete .. " Toggle Deleted" },
      l = { safe_fn("open_changed_files", "List Changed Files"), desc = icons_map.list .. " List Changed Files" },
    },
  }

  logger.debug("[Defs/Git] Mapeamentos gerados.")
  return mappings
end

return M

