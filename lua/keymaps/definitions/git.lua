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

  -- Ícones padrão
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
  }

  local function safe_fn(fn_name, desc)
    if type(git_fns[fn_name]) == "function" then
      return git_fns[fn_name]
    else
      return function()
        logger.warn("[Defs/Git] Função '" .. fn_name .. "' não disponível. Ação: " .. desc)
      end
    end
  end

  -- Mapeamentos sob <leader>g
  local mappings = {
    ["<leader>g"] = {
      name = icons_map.repo .. " Git",

      -- Hunk actions
      s = { safe_fn("stage_hunk", "Stage Hunk"), desc = icons_map.add .. " Stage Hunk" },
      r = { safe_fn("reset_hunk", "Reset Hunk"), desc = icons_map.delete .. " Reset Hunk" },
      u = { safe_fn("undo_stage_hunk", "Undo Stage Hunk"), desc = icons_map.stash .. " Undo Stage Hunk" },
      p = { safe_fn("preview_hunk", "Preview Hunk"), desc = icons_map.diff .. " Preview Hunk" },
      b = { safe_fn("toggle_blame_line", "Toggle Blame Line"), desc = icons_map.commit .. " Toggle Blame Line" },

      -- Buffer hunk actions
      S = { safe_fn("stage_buffer", "Stage Buffer"), desc = icons_map.add .. " Stage Buffer" },
      R = { safe_fn("reset_buffer", "Reset Buffer"), desc = icons_map.delete .. " Reset Buffer" },

      -- Diffview
      d = { safe_fn("diff_this", "Diff This (HEAD)"), desc = icons_map.diff .. " Diff This (HEAD)" },
      D = { safe_fn("diff_this_prev", "Diff This Prev"), desc = icons_map.diff .. " Diff This Prev" },
      o = { safe_fn("diffview_open", "Open Diffview"), desc = icons_map.diff .. " Diffview Open" },
      c = { safe_fn("diffview_close", "Close Diffview"), desc = icons_map.diff .. " Diffview Close" },
      h = { safe_fn("diffview_file_history", "File History"), desc = icons_map.diff .. " File History" },

      -- Fugitive
      g = { "<cmd>Git<cr>", desc = icons_map.branch .. " Status" },
      P = { "<cmd>Git push<cr>", desc = icons_map.branch .. " Push" },
      L = { "<cmd>Git pull<cr>", desc = icons_map.branch .. " Pull" },
      c = { "<cmd>Git commit<cr>", desc = icons_map.commit .. " Commit" },
      B = { "<cmd>Git blame<cr>", desc = icons_map.commit .. " Blame (Fugitive)" },
      C = { "<cmd>Git commit --amend<cr>", desc = icons_map.commit .. " Amend Commit" },

      -- Branching
      b = { safe_fn("list_branches", "List Branches"), desc = icons_map.branch .. " Branches" },
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

