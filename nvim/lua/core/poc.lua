-- ~/.config/nvim/lua/core/poc.lua
local M = {}
local init_utils = require("core.init_utils")

-- Test configuration
local test_config = {
  name = "Neovim POC",
  version = "1.0.0",
  features = {
    "Modular Initialization",
    "Enhanced Error Handling",
    "Performance Monitoring",
    "Health Checks"
  }
}

-- Performance test function
function M.run_performance_test()
  local start_time = vim.loop.hrtime()
  local results = {}
  
  -- Test module loading
  local modules_to_test = {
    "core.options",
    "core.keymaps",
    "core.debug.logger"
  }
  
  for _, module in ipairs(modules_to_test) do
    local module_start = vim.loop.hrtime()
    local ok, _ = init_utils.safe_require(module)
    local module_time = (vim.loop.hrtime() - module_start) / 1e6
    
    table.insert(results, {
      module = module,
      success = ok,
      load_time = module_time
    })
  end
  
  -- Test health check
  local health_ok, health_issues = init_utils.health_check(modules_to_test)
  
  -- Calculate total time
  local total_time = (vim.loop.hrtime() - start_time) / 1e6
  
  return {
    config = test_config,
    performance = {
      total_time = total_time,
      module_results = results
    },
    health = {
      ok = health_ok,
      issues = health_issues
    }
  }
end

-- Display results in a nice format
function M.show_results()
  local results = M.run_performance_test()
  
  -- Create a new buffer for results
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}
  
  -- Format header
  table.insert(lines, string.format("=== %s v%s ===", results.config.name, results.config.version))
  table.insert(lines, "")
  
  -- Format features
  table.insert(lines, "Features:")
  for _, feature in ipairs(results.config.features) do
    table.insert(lines, "  • " .. feature)
  end
  table.insert(lines, "")
  
  -- Format performance results
  table.insert(lines, "Performance Results:")
  table.insert(lines, string.format("  Total Time: %.2fms", results.performance.total_time))
  table.insert(lines, "")
  table.insert(lines, "Module Load Times:")
  for _, result in ipairs(results.performance.module_results) do
    local status = result.success and "✓" or "✗"
    table.insert(lines, string.format("  %s %s: %.2fms", 
      status, result.module, result.load_time))
  end
  table.insert(lines, "")
  
  -- Format health check results
  table.insert(lines, "Health Check:")
  if results.health.ok then
    table.insert(lines, "  ✓ All systems operational")
  else
    table.insert(lines, "  ✗ Issues found:")
    for _, issue in ipairs(results.health.issues) do
      table.insert(lines, "    • " .. issue)
    end
  end
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_name(buf, "Neovim POC Results")
  
  -- Create window
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(20, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded"
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(win, "wrap", true)
  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)
  vim.api.nvim_win_set_option(win, "cursorline", false)
  
  -- Add keymaps
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })
end

-- Command to run the POC
vim.api.nvim_create_user_command("POC", function()
  M.show_results()
end, {
  desc = "Run the Neovim configuration Proof of Concept"
})

return M 