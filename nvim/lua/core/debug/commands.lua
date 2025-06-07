-- nvim/lua/core/debug/commands.lua
local M = {}

local stress_test = require("core.debug.stress_test")
local logger = require("core.debug.logger")
local log = logger.get_logger("debug.commands")

-- Register commands
local function register_commands()
    -- Start stress test
    vim.api.nvim_create_user_command("DebugStressStart", function()
        stress_test.start()
        log.info("Stress test started via command")
    end, { desc = "Start Neovim stress test" })

    -- Stop stress test
    vim.api.nvim_create_user_command("DebugStressStop", function()
        local report = stress_test.stop()
        log.info("Stress test stopped via command")
        
        -- Show report in a new buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            "=== Stress Test Report ===",
            "Duration: " .. report.duration .. " seconds",
            "",
            "Memory Usage:",
            vim.inspect(report.memory_checks),
            "",
            "LSP Stats:",
            vim.inspect(report.lsp_stats),
            "",
            "Plugin Stats:",
            vim.inspect(report.plugin_stats),
            "",
            "Performance:",
            vim.inspect(report.performance)
        })
        vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = math.floor(vim.o.columns * 0.8),
            height = math.floor(vim.o.lines * 0.8),
            col = math.floor(vim.o.columns * 0.1),
            row = math.floor(vim.o.lines * 0.1),
            style = "minimal",
            border = "rounded"
        })
    end, { desc = "Stop Neovim stress test and show report" })

    -- Run specific scenario
    vim.api.nvim_create_user_command("DebugStressScenario", function(opts)
        local scenario = stress_test.scenarios[opts.args]
        if not scenario then
            log.error("Unknown scenario: " .. opts.args)
            return
        end
        
        local ok, result = stress_test.run_scenario(opts.args, scenario)
        if not ok then
            log.error("Scenario failed: " .. tostring(result))
        end
    end, {
        nargs = 1,
        complete = function()
            return vim.tbl_keys(stress_test.scenarios)
        end,
        desc = "Run specific stress test scenario"
    })

    -- Show current status
    vim.api.nvim_create_user_command("DebugStressStatus", function()
        local status = stress_test.status()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            "=== Stress Test Status ===",
            "Running: " .. tostring(status.running),
            "Duration: " .. status.duration .. " seconds",
            "Memory Checks: " .. status.memory_checks,
            "",
            "LSP Clients:",
            vim.inspect(status.lsp_clients),
            "",
            "Plugins:",
            vim.inspect(status.plugins)
        })
        vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = math.floor(vim.o.columns * 0.6),
            height = math.floor(vim.o.lines * 0.6),
            col = math.floor(vim.o.columns * 0.2),
            row = math.floor(vim.o.lines * 0.2),
            style = "minimal",
            border = "rounded"
        })
    end, { desc = "Show current stress test status" })
end

-- Initialize commands
register_commands()

return M 