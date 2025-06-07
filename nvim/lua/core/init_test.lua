-- nvim/lua/core/init_test.lua
local M = {}
local init_utils = require("core.init_utils")

-- Test configuration
local test_config = {
  name = "Neovim Init Test",
  version = "1.0.0",
  tests = {
    "Core Loading",
    "Plugin Loading",
    "Debug System",
    "Performance",
    "Error Handling"
  }
}

-- Performance metrics
local metrics = {
  start_time = vim.loop.hrtime(),
  module_load_times = {},
  plugin_load_times = {},
  errors = {},
  warnings = {}
}

-- Test core module loading
function M.test_core_loading()
  local core_modules = {
    "core.options",
    "core.keymaps",
    "core.debug.logger",
    "core.appearance"
  }
  
  for _, module in ipairs(core_modules) do
    local start_time = vim.loop.hrtime()
    local ok, result = init_utils.safe_require(module)
    local load_time = (vim.loop.hrtime() - start_time) / 1e6
    
    table.insert(metrics.module_load_times, {
      module = module,
      success = ok,
      time = load_time,
      error = not ok and result or nil
    })
  end
end

-- Test plugin loading
function M.test_plugin_loading()
  local plugin_categories = {
    "plugins.ui",
    "plugins.dev",
    "plugins.productivity"
  }
  
  for _, category in ipairs(plugin_categories) do
    local start_time = vim.loop.hrtime()
    local ok, result = init_utils.safe_require(category)
    local load_time = (vim.loop.hrtime() - start_time) / 1e6
    
    table.insert(metrics.plugin_load_times, {
      category = category,
      success = ok,
      time = load_time,
      error = not ok and result or nil
    })
  end
end

-- Test debug system
function M.test_debug_system()
  local debug = require("core.debug.logger")
  if debug then
    debug.info("[TEST] Debug system test message")
    debug.warn("[TEST] Debug system warning test")
    debug.error("[TEST] Debug system error test")
  else
    table.insert(metrics.errors, "Debug system not available")
  end
end

-- Run all tests
function M.run_tests()
  M.test_core_loading()
  M.test_plugin_loading()
  M.test_debug_system()
  
  -- Calculate total time
  metrics.total_time = (vim.loop.hrtime() - metrics.start_time) / 1e6
  
  -- Display results
  M.show_results()
end

-- Display test results
function M.show_results()
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}
  
  -- Header
  table.insert(lines, string.format("=== %s v%s ===", test_config.name, test_config.version))
  table.insert(lines, "")
  
  -- Test categories
  table.insert(lines, "Test Categories:")
  for _, test in ipairs(test_config.tests) do
    table.insert(lines, "  • " .. test)
  end
  table.insert(lines, "")
  
  -- Performance results
  table.insert(lines, "Performance Results:")
  table.insert(lines, string.format("  Total Time: %.2fms", metrics.total_time))
  table.insert(lines, "")
  
  -- Module load times
  table.insert(lines, "Core Module Load Times:")
  for _, result in ipairs(metrics.module_load_times) do
    local status = result.success and "✓" or "✗"
    table.insert(lines, string.format("  %s %s: %.2fms", 
      status, result.module, result.time))
    if not result.success then
      table.insert(lines, string.format("    Error: %s", result.error))
    end
  end
  table.insert(lines, "")
  
  -- Plugin load times
  table.insert(lines, "Plugin Category Load Times:")
  for _, result in ipairs(metrics.plugin_load_times) do
    local status = result.success and "✓" or "✗"
    table.insert(lines, string.format("  %s %s: %.2fms", 
      status, result.category, result.time))
    if not result.success then
      table.insert(lines, string.format("    Error: %s", result.error))
    end
  end
  table.insert(lines, "")
  
  -- Errors and warnings
  if #metrics.errors > 0 then
    table.insert(lines, "Errors:")
    for _, error in ipairs(metrics.errors) do
      table.insert(lines, "  • " .. error)
    end
    table.insert(lines, "")
  end
  
  if #metrics.warnings > 0 then
    table.insert(lines, "Warnings:")
    for _, warning in ipairs(metrics.warnings) do
      table.insert(lines, "  • " .. warning)
    end
    table.insert(lines, "")
  end
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_name(buf, "Neovim Init Test Results")
  
  -- Create window
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(30, vim.o.lines - 4)
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

-- Command to run the tests
vim.api.nvim_create_user_command("InitTest", function()
  M.run_tests()
end, {
  desc = "Run Neovim initialization tests"
})

return M 