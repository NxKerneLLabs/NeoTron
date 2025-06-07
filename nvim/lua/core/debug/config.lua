-- nvim/lua/core/debug/config.lua
-- Configuration for the debug system

local M = {}

--tls_cert = "/caminho/para/server.crt",
--tls_key  = "/caminho/para/server.key",

-- Default log file and levels
M.log_file         = vim.fn.stdpath("data") .. "/nvim-debug.log"
M.log_level        = vim.log.levels.DEBUG
M.max_file_size    = 1024 * 1024 * 10    -- 10 MB for stress testing
M.enabled          = true
M.buffer_size      = 1000                -- Increased for stress testing
M.flush_interval   = 1000                -- 1 second for real-time monitoring
M.stacktrace_depth = 20                  -- Increased for better debugging

-- Advanced features
M.silent_mode      = false              -- Keep notifications for stress testing
M.compress_backups = true               -- Compress log backups
M.performance_log  = true               -- Enable performance logging
M.stress_test      = true               -- Enable stress test mode

-- Stress test specific settings
M.stress_test_config = {
    memory_check_interval = 1000,        -- Check memory every second
    max_memory_usage = 1024 * 1024 * 500, -- 500MB warning threshold
    event_tracking = {
        enabled = true,
        events = {
            "BufEnter", "BufLeave",
            "WinEnter", "WinLeave",
            "CmdlineEnter", "CmdlineLeave",
            "TextChanged", "TextChangedI",
            "InsertEnter", "InsertLeave",
            "ModeChanged"
        }
    },
    lsp_monitoring = {
        enabled = true,
        check_interval = 2000,           -- Check LSP status every 2 seconds
        timeout = 5000                   -- LSP operation timeout
    },
    plugin_performance = {
        enabled = true,
        track_load_time = true,
        track_memory_usage = true
    }
}

-- Namespace-specific log levels
M.namespaces = {
    ["global"]     = vim.log.levels.INFO,
    ["stress_test"] = vim.log.levels.DEBUG,
    ["lsp"]        = vim.log.levels.INFO,
    ["plugin"]     = vim.log.levels.DEBUG,
    ["memory"]     = vim.log.levels.WARN,
    ["performance"] = vim.log.levels.DEBUG,
    ["default"]    = vim.log.levels.DEBUG,
}

-- Performance thresholds
M.performance_thresholds = {
    startup_time = 1000,                -- 1 second
    plugin_load_time = 500,             -- 500ms
    buffer_open_time = 100,             -- 100ms
    lsp_init_time = 2000,               -- 2 seconds
    memory_warning = 1024 * 1024 * 200, -- 200MB
    memory_critical = 1024 * 1024 * 500 -- 500MB
}

--- Update configuration at runtime
-- @param new_cfg table of keys to update
-- @return updated config table
function M.update(new_cfg)
    if type(new_cfg) ~= "table" then
        vim.notify("[debug.config] update() requires a table", vim.log.levels.WARN)
        return M
    end
    
    -- Deep merge for nested tables
    for k, v in pairs(new_cfg) do
        if type(v) == "table" and type(M[k]) == "table" then
            M[k] = vim.tbl_deep_extend("force", M[k], v)
        else
            M[k] = v
        end
    end
    
    return M
end

return M

