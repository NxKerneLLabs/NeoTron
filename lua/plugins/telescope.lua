-- nvim/lua/plugins/telescope.lua
-- Plugin specifications for Telescope, project management, and code navigation.
local function safe_require(mod)
  local ok, res = pcall(require, mod)
  return ok and res or nil
end

local M = {}
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "ahmedkhalf/project.nvim",
    },
    config = function()
      -- Logger factory
      local function get_logger(ns)
        local ok, dbg = pcall(require, "core.debug.logger")
        if ok and type(dbg.get_logger) == "function" then
          local L = dbg.get_logger(ns)
          if type(L.success) ~= "function" then
            L.success = function(msg) L.info("✔️ " .. msg) end
          end
          return L
        end
        return {
          info    = function(m) print("INFO ["..ns.."] "..m) end,
          warn    = function(m) print("WARN ["..ns.."] "..m) end,
          error   = function(m) print("ERROR ["..ns.."] "..m) end,
          debug   = function(m) print("DEBUG ["..ns.."] "..m) end,
          success = function(m) print("✔️ ["..ns.."] "..m) end,
        }
      end
      local logger = get_logger("plugins.telescope")

      logger.info("Configuring telescope.nvim...")
      local ok, telescope = pcall(require, "telescope")
      if not ok then return logger.error("telescope module not found: "..tostring(telescope)) end

      -- Actions and layout
      local actions = (pcall(require, "telescope.actions") and require("telescope.actions")) or nil
      local actions_layout = (pcall(require, "telescope.actions.layout") and require("telescope.actions.layout")) or nil
      if not actions or not actions_layout then
        logger.warn("Some telescope actions modules failed to load.")
      end

      -- Icons
      local ui_icons = (pcall(require, "utils.icons") and require("utils.icons").ui) or {}
      local icons = {
        prompt    = (ui_icons.Telescope or ui_icons.Search or "") .. " ",
        selection = (ui_icons.ChevronRight or "") .. " ",
        multi     = (ui_icons.BoldClose or "") .. " ",
      }
      -- Custom actions
      local custom = {}
      do
        local ok_mt, mt = pcall(require, "telescope.actions.mt")
        if ok_mt and mt then
          custom = mt.transform_mod({
            open_in_vscode = function(bufnr)
              local sel = require("telescope.actions.state").get_selected_entry()
              if not sel then return logger.warn("No selection for VSCode") end
              local path = sel.filename or sel.value
              if actions then actions.close(bufnr) end
              vim.fn.system({ "code", "--goto", path })
              logger.info("Opened in VSCode: "..path)
            end,
            open_in_tabs = function(bufnr)
              if not actions then return logger.warn("Actions missing for tabs") end
              local picker = require("telescope.actions.state").get_current_picker(bufnr)
              local sel = picker:get_multi_selection()
              actions.close(bufnr)
              for _, e in ipairs(sel) do
                local p = e.value or e.filename
                if p then vim.cmd("tabedit "..vim.fn.fnameescape(p)) end
              end
              logger.info("Opened "..#sel.." in tabs.")
            end,
          })
        else
          logger.warn("telescope.actions.mt not available: "..tostring(mt))
        end
      end

      telescope.setup({
        defaults = {
          prompt_prefix    = icons.prompt,
          selection_caret  = icons.selection,
          multi_icon       = icons.multi,
          sorting_strategy = "ascending",
          layout_strategy  = "horizontal",
          layout_config    = { horizontal = { prompt_position = "top", preview_width = 0.55, results_width = 0.8 }, width = 0.87, height = 0.80 },
          file_ignore_patterns = {"node_modules","%.git/","dist/"},
          mappings = {
            i = {
              ["<C-c>"] = actions and actions.close,
              ["<esc>"] = actions and actions.close,
              ["<C-j>"] = actions and actions.move_selection_next,
              ["<C-k>"] = actions and actions.move_selection_previous,
              ["<C-q>"] = actions and function(b) actions.smart_send_to_qflist(b); actions.open_qflist(b) end,
              ["<C-t>"] = custom.open_in_tabs,
              ["<C-p>"] = actions_layout and actions_layout.toggle_preview,
            },
            n = {
              ["q"]    = actions and actions.close,
              ["<C-t>"] = custom.open_in_tabs,
              ["<C-p>"] = actions_layout and actions_layout.toggle_preview,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
          live_grep  = { additional_args = function() return {"--hidden"} end },
        },
        extensions = {
          ["fzf"] = { fuzzy = true, override_generic_sorter = true },
          ["ui-select"] = (pcall(require, "telescope.themes") and require("telescope.themes").get_dropdown()) or {},
        },
      })
      logger.success("telescope.setup() completed.")

      -- Safely load extensions (use 'project' instead of 'project_nvim')
      for _, ext in ipairs({"fzf","ui-select","projects"}) do
        local ok_ext, err = pcall(telescope.load_extension, ext)
        if ok_ext then
          logger.success("Loaded extension: "..ext)
        else
          logger.warn("Could not load extension '"..ext.."': "..tostring(err))
        end
      end

      logger.info("telescope.nvim configured successfully.")
    end,
  },
}

