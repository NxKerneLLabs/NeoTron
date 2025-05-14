-- nvim/lua/keymaps/which-key/git.lua
-- Registers Git related keybindings (Gitsigns, Fugitive, Diffview) with which-key.nvim

local M = {}

function M.register(wk_instance, logger)
  if not logger then
    print("ERROR [keymaps.which-key.git]: Logger not provided. Using fallback print.")
    logger = {
      info = function(msg) print("INFO [KWGIT_FB]: " .. msg) end,
      error = function(msg) print("ERROR [KWGIT_FB]: " .. msg) end,
      warn = function(msg) print("WARN [KWGIT_FB]: " .. msg) end,
      debug = function(msg) print("DEBUG [KWGIT_FB]: " .. msg) end,
    }
  end

  if not wk_instance then
    logger.error("which-key instance not provided. Cannot register Git keymaps.")
    return
  end

  local git_fns_ok, git_fns = pcall(require, "functions.git")
  if not git_fns_ok then
    logger.warn("'functions.git' module not found or failed to load. Gitsigns/Diffview specific functions might not work. Error: " .. tostring(git_fns))
    git_fns = {} -- Provide an empty table to prevent errors when trying to access git_fns.action
  end

  local icons_ok, icons = pcall(require, "utils.icons")
  if not icons_ok then
    logger.warn("'utils.icons' module not found. Using text fallbacks for Git which-key names. Error: " .. tostring(icons))
    icons = { git = {}, misc = {}, ui = {} } -- Basic fallback
  else
    icons.git = icons.git or {}
    icons.misc = icons.misc or {}
    icons.ui = icons.ui or {} -- Ensure ui sub-table exists for potential future use
  end

  local git_group_icon = icons.git.Repo or ""
  local fugitive_icon = icons.git.Branch or ""
  local gitsigns_stage_icon = icons.git.Staged or "✓"
  local gitsigns_reset_icon = icons.git.Unstaged or "✗"
  local gitsigns_undo_icon = icons.git.Stash or "󰚫" -- Or a specific undo icon
  local gitsigns_preview_icon = icons.git.Diff or ""
  local gitsigns_blame_icon = icons.git.Commit or "" -- Or a blame specific icon
  local gitsigns_select_hunk_icon = icons.misc.List or ""
  local diffview_icon = icons.git.Diff or ""


  -- Helper to create a safe function call for git_fns
  local function make_safe_git_fn(fn_name, default_desc)
    if git_fns and type(git_fns[fn_name]) == "function" then
      return git_fns[fn_name]
    else
      return function()
        logger.warn("Git function '" .. fn_name .. "' not available from 'functions.git'. Action: " .. default_desc)
      end
    end
  end

  local git_mappings_table = {
    ["<leader>g"] = {
      name = git_group_icon .. " Git Actions", -- This defines the main group name

      -- Gitsigns - these are now direct children of <leader>g
      s = { make_safe_git_fn("stage_hunk", "Stage Hunk"), gitsigns_stage_icon .. " Stage Hunk" },
      r = { make_safe_git_fn("reset_hunk", "Reset Hunk"), gitsigns_reset_icon .. " Reset Hunk" },
      u = { make_safe_git_fn("undo_stage_hunk", "Undo Stage Hunk"), gitsigns_undo_icon .. " Undo Stage Hunk" },
      S = { make_safe_git_fn("stage_buffer", "Stage Buffer"), gitsigns_stage_icon .. " Stage Buffer" },
      R = { make_safe_git_fn("reset_buffer", "Reset Buffer"), gitsigns_reset_icon .. " Reset Buffer" },
      p = { make_safe_git_fn("preview_hunk", "Preview Hunk"), gitsigns_preview_icon .. " Preview Hunk" },
      B = { make_safe_git_fn("toggle_line_blame", "Toggle Blame"), gitsigns_blame_icon .. " Toggle Blame" }, -- Was gs.toggle_current_line_blame in gitsigns
      d = { make_safe_git_fn("diff_this", "Diff This (HEAD)"), gitsigns_preview_icon .. " Diff This (HEAD)" },
      D = { make_safe_git_fn("diff_this_prev", "Diff This (~)"), gitsigns_preview_icon .. " Diff This (~)" },
      H = { make_safe_git_fn("select_hunk", "Select Hunk"), gitsigns_select_hunk_icon .. " Select Hunk" },

      -- Fugitive Keymaps - direct children of <leader>g
      g = { "<cmd>Git<cr>", fugitive_icon .. " Fugitive Status" }, -- <leader>gg
      P = { "<cmd>Git push<cr>", fugitive_icon .. " Git Push" },   -- <leader>gP
      L = { "<cmd>Git pull<cr>", fugitive_icon .. " Git Pull" },   -- <leader>gL
      b = { "<cmd>Git blame<cr>", fugitive_icon .. " Git Blame" }, -- <leader>gb (Fugitive)

      -- Diffview - direct children of <leader>g
      vo = { make_safe_git_fn("diffview_open", "Diffview Open"), diffview_icon .. " Diffview Open" },
      vc = { make_safe_git_fn("diffview_close", "Diffview Close"), diffview_icon .. " Diffview Close" },
      vh = { make_safe_git_fn("diffview_file_history", "Diffview File History"), diffview_icon .. " Diffview File History" },
    },
  }

  local reg_ok, reg_err = pcall(wk_instance.register, git_mappings_table)
  if reg_ok then
    logger.info("Git (Gitsigns, Fugitive, Diffview) keymaps registered with which-key.")
  else
    logger.error("Failed to register Git keymaps with which-key: " .. tostring(reg_err))
  end
end

return M

