-- Caminho Sugerido: lua/keymaps/definitions/git.lua
-- (Anteriormente: nvim/lua/keymaps/which-key/git.lua)

local M = {}

function M.get_mappings(icons, logger)
  logger.debug("[Defs/Git] Gerando mapeamentos para Git...")

  local git_fns_ok, git_fns = pcall(require, "functions.git")
  if not git_fns_ok then
    logger.warn("[Defs/Git] 'functions.git' não encontrado. Funções específicas podem não funcionar. Erro: " .. tostring(git_fns))
    git_fns = {} -- Fallback para evitar erros
  end

  local git_icons_map = (icons and icons.git) or {}
  local misc_icons = (icons and icons.misc) or {}
  -- local ui_icons = (icons and icons.ui) or {} -- Descomente se usar icones de ui

  local git_group_icon          = git_icons_map.Repo      or ""
  local fugitive_icon           = git_icons_map.Branch    or ""
  local gitsigns_stage_icon     = git_icons_map.Staged    or "✓"
  local gitsigns_reset_icon     = git_icons_map.Unstaged  or "✗"
  local gitsigns_undo_icon      = git_icons_map.Stash     or "󰚫"
  local gitsigns_preview_icon   = git_icons_map.Diff      or ""
  local gitsigns_blame_icon     = git_icons_map.Commit    or ""
  local gitsigns_select_hunk_icon = misc_icons.List     or ""
  local diffview_icon           = git_icons_map.Diff      or ""

  local function make_safe_git_fn(fn_name, default_desc)
    if git_fns and type(git_fns[fn_name]) == "function" then
      return git_fns[fn_name]
    else
      return function()
        logger.warn("[Defs/Git] Função Git '" .. fn_name .. "' não disponível. Ação: " .. default_desc)
      end
    end
  end

  -- Estes mapeamentos incluem o prefixo <leader>g.
  -- O orquestrador deve registrar este módulo com prefix = "".
  local mappings = {
    ["<leader>g"] = {
      name = git_group_icon .. " Git Actions",

      s = { make_safe_git_fn("stage_hunk", "Stage Hunk"), desc = gitsigns_stage_icon .. " Stage Hunk" },
      r = { make_safe_git_fn("reset_hunk", "Reset Hunk"), desc = gitsigns_reset_icon .. " Reset Hunk" },
      u = { make_safe_git_fn("undo_stage_hunk", "Undo Stage Hunk"), desc = gitsigns_undo_icon .. " Undo Stage Hunk" },
      S = { make_safe_git_fn("stage_buffer", "Stage Buffer"), desc = gitsigns_stage_icon .. " Stage Buffer" },
      R = { make_safe_git_fn("reset_buffer", "Reset Buffer"), desc = gitsigns_reset_icon .. " Reset Buffer" },
      p = { make_safe_git_fn("preview_hunk", "Preview Hunk"), desc = gitsigns_preview_icon .. " Preview Hunk" },
      B = { make_safe_git_fn("toggle_line_blame", "Toggle Blame"), desc = gitsigns_blame_icon .. " Toggle Blame" },
      d = { make_safe_git_fn("diff_this", "Diff This (HEAD)"), desc = gitsigns_preview_icon .. " Diff This (HEAD)" },
      D = { make_safe_git_fn("diff_this_prev", "Diff This (~)"), desc = gitsigns_preview_icon .. " Diff This (~)" },
      H = { make_safe_git_fn("select_hunk", "Select Hunk"), desc = gitsigns_select_hunk_icon .. " Select Hunk" },

      g = { "<cmd>Git<cr>", desc = fugitive_icon .. " Fugitive Status" },
      P = { "<cmd>Git push<cr>", desc = fugitive_icon .. " Git Push" },
      L = { "<cmd>Git pull<cr>", desc = fugitive_icon .. " Git Pull" },
      b = { "<cmd>Git blame<cr>", desc = fugitive_icon .. " Git Blame (Fugitive)" },

      vo = { make_safe_git_fn("diffview_open", "Diffview Open"), desc = diffview_icon .. " Diffview Open" },
      vc = { make_safe_git_fn("diffview_close", "Diffview Close"), desc = diffview_icon .. " Diffview Close" },
      vh = { make_safe_git_fn("diffview_file_history", "Diffview File History"), desc = diffview_icon .. " Diffview File History" },
    },
  }
  logger.debug("[Defs/Git] Mapeamentos gerados.")
  return mappings
end

return M
