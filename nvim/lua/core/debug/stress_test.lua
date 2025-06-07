-- nvim/lua/core/debug/stress_test.lua
local M = {}

local config = require("core.debug.config")
local logger = require("core.debug.logger")
local profiler = require("core.debug.profiler")
local inspector = require("core.debug.inspector")
local events = require("core.debug.events")

local log = logger.get_logger("stress_test")

-- State tracking
local state = {
    running = false,
    start_time = 0,
    memory_checks = {},
    event_counts = {},
    lsp_stats = {},
    plugin_stats = {}
}

-- Memory monitoring
local function check_memory()
    if not state.running then return end
    
    local mem_usage = collectgarbage("count")
    table.insert(state.memory_checks, {
        time = os.time(),
        usage = mem_usage
    })
    
    -- Check thresholds
    if mem_usage > config.performance_thresholds.memory_critical then
        log.error("Critical memory usage: " .. mem_usage .. "KB")
    elseif mem_usage > config.performance_thresholds.memory_warning then
        log.warn("High memory usage: " .. mem_usage .. "KB")
    end
    
    -- Schedule next check
    vim.defer_fn(check_memory, config.stress_test_config.memory_check_interval)
end

-- Event tracking
local function track_events()
    if not state.running then return end
    
    events.track_events(config.stress_test_config.event_tracking.events, "stress_test")
    log.info("Event tracking started")
end

-- LSP monitoring
local function monitor_lsp()
    if not state.running then return end
    
    local clients = vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
        if not state.lsp_stats[client.name] then
            state.lsp_stats[client.name] = {
                start_time = os.time(),
                operations = 0,
                errors = 0
            }
        end
    end
    
    -- Schedule next check
    vim.defer_fn(monitor_lsp, config.stress_test_config.lsp_monitoring.check_interval)
end

-- Plugin performance tracking
local function track_plugin_performance()
    if not state.running then return end
    
    for _, plugin in ipairs(vim.fn.globpath(vim.fn.stdpath("data").."/lazy/*", 0, 1)) do
        local name = vim.fn.fnamemodify(plugin, ":t")
        if not state.plugin_stats[name] then
            state.plugin_stats[name] = {
                load_time = 0,
                memory_usage = 0
            }
        end
    end
end

-- Start stress test
function M.start()
    if state.running then
        log.warn("Stress test already running")
        return
    end
    
    state.running = true
    state.start_time = os.time()
    state.memory_checks = {}
    state.event_counts = {}
    state.lsp_stats = {}
    state.plugin_stats = {}
    
    -- Start profiling
    profiler.start("stress_test")
    
    -- Initialize monitoring
    check_memory()
    track_events()
    monitor_lsp()
    track_plugin_performance()
    
    log.info("Stress test started")
end

-- Stop stress test
function M.stop()
    if not state.running then
        log.warn("No stress test running")
        return
    end
    
    state.running = false
    profiler.stop("stress_test")
    
    -- Generate report
    local report = {
        duration = os.time() - state.start_time,
        memory_checks = state.memory_checks,
        lsp_stats = state.lsp_stats,
        plugin_stats = state.plugin_stats,
        performance = profiler.report("stress_test")
    }
    
    log.info("Stress test completed", report)
    return report
end

-- Get current status
function M.status()
    return {
        running = state.running,
        duration = state.running and (os.time() - state.start_time) or 0,
        memory_checks = #state.memory_checks,
        lsp_clients = vim.tbl_keys(state.lsp_stats),
        plugins = vim.tbl_keys(state.plugin_stats)
    }
end

-- Run a specific stress test scenario
function M.run_scenario(name, scenario_func)
    if not state.running then
        log.warn("Start stress test first")
        return
    end
    
    log.info("Running scenario: " .. name)
    profiler.start(name)
    
    local ok, result = pcall(scenario_func)
    
    profiler.stop(name)
    if not ok then
        log.error("Scenario failed: " .. tostring(result))
    else
        log.info("Scenario completed: " .. name)
    end
    
    return ok, result
end

-- Predefined scenarios
M.scenarios = {
    -- Buffer operations
    buffer_ops = function()
        local buf_count = 100
        local bufs = {}
        
        -- Create buffers
        for i = 1, buf_count do
            local buf = vim.api.nvim_create_buf(false, true)
            table.insert(bufs, buf)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
                "Test line " .. i,
                "Another test line " .. i
            })
        end
        
        -- Switch between buffers
        for _ = 1, 50 do
            local random_buf = bufs[math.random(1, #bufs)]
            vim.api.nvim_set_current_buf(random_buf)
        end
        
        -- Cleanup
        for _, buf in ipairs(bufs) do
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end,
    
    -- LSP operations
    lsp_ops = function()
        local clients = vim.lsp.get_active_clients()
        for _, client in ipairs(clients) do
            -- Request document symbols
            client.request("textDocument/documentSymbol", {
                textDocument = {
                    uri = vim.uri_from_bufnr(0)
                }
            })
        end
    end,
    
    -- Plugin operations
    plugin_ops = function()
        -- Simulate plugin operations
        vim.cmd("Telescope find_files")
        vim.cmd("NvimTreeToggle")
        vim.cmd("WhichKey")
    end
}

return M 