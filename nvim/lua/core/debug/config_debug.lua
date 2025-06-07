-- nvim/lua/core/debug/config_debug.lua
local M = {}

local logger = require("core.debug.logger")
local log = logger.get_logger("config_debug")

-- Configuration validation rules
local validation_rules = {
    options = {
        required = {
            "tabstop",
            "shiftwidth",
            "expandtab",
            "number",
            "relativenumber",
            "termguicolors"
        },
        numeric = {
            "tabstop",
            "shiftwidth",
            "updatetime",
            "timeoutlen"
        },
        boolean = {
            "expandtab",
            "number",
            "relativenumber",
            "termguicolors",
            "wrap",
            "smartindent"
        }
    },
    globals = {
        required = {
            "mapleader",
            "maplocalleader"
        }
    },
    plugins = {
        required = {
            "lazy.nvim",
            "nvim-treesitter"
        }
    }
}

-- Check if a plugin is loaded
local function is_plugin_loaded(name)
    return package.loaded[name] ~= nil
end

-- Validate Neovim options
local function validate_options()
    local issues = {}
    local opt = vim.opt

    -- Check required options
    for _, option in ipairs(validation_rules.options.required) do
        if opt[option]:get() == nil then
            table.insert(issues, "Missing required option: " .. option)
        end
    end

    -- Check numeric options
    for _, option in ipairs(validation_rules.options.numeric) do
        local value = opt[option]:get()
        if type(value) ~= "number" then
            table.insert(issues, "Invalid numeric option " .. option .. ": " .. tostring(value))
        end
    end

    -- Check boolean options
    for _, option in ipairs(validation_rules.options.boolean) do
        local value = opt[option]:get()
        if type(value) ~= "boolean" then
            table.insert(issues, "Invalid boolean option " .. option .. ": " .. tostring(value))
        end
    end

    return issues
end

-- Validate global variables
local function validate_globals()
    local issues = {}
    local g = vim.g

    for _, var in ipairs(validation_rules.globals.required) do
        if g[var] == nil then
            table.insert(issues, "Missing required global: " .. var)
        end
    end

    return issues
end

-- Validate plugins
local function validate_plugins()
    local issues = {}
    local loaded_plugins = {}

    -- Check required plugins
    for _, plugin in ipairs(validation_rules.plugins.required) do
        if not is_plugin_loaded(plugin) then
            table.insert(issues, "Missing required plugin: " .. plugin)
        else
            loaded_plugins[plugin] = true
        end
    end

    return issues, loaded_plugins
end

-- Check for conflicting configurations
local function check_conflicts()
    local conflicts = {}
    local opt = vim.opt

    -- Check for conflicting options
    if opt.number:get() and opt.relativenumber:get() then
        table.insert(conflicts, "Both number and relativenumber are enabled")
    end

    if opt.expandtab:get() and opt.tabstop:get() ~= opt.shiftwidth:get() then
        table.insert(conflicts, "tabstop and shiftwidth are different with expandtab enabled")
    end

    return conflicts
end

-- Generate configuration report
function M.generate_report()
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        options = {
            current = vim.tbl_map(function(opt) return opt:get() end, vim.opt),
            issues = validate_options()
        },
        globals = {
            current = vim.g,
            issues = validate_globals()
        },
        plugins = {
            issues = {},
            loaded = {}
        },
        conflicts = check_conflicts()
    }

    report.plugins.issues, report.plugins.loaded = validate_plugins()

    return report
end

-- Show configuration report in a buffer
function M.show_report()
    local report = M.generate_report()
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = {
        "=== Neovim Configuration Report ===",
        "Generated: " .. report.timestamp,
        "",
        "Options:",
        vim.inspect(report.options.current),
        "",
        "Option Issues:",
        vim.inspect(report.options.issues),
        "",
        "Global Variables:",
        vim.inspect(report.globals.current),
        "",
        "Global Issues:",
        vim.inspect(report.globals.issues),
        "",
        "Plugin Issues:",
        vim.inspect(report.plugins.issues),
        "",
        "Loaded Plugins:",
        vim.inspect(report.plugins.loaded),
        "",
        "Configuration Conflicts:",
        vim.inspect(report.conflicts)
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        col = math.floor(vim.o.columns * 0.1),
        row = math.floor(vim.o.lines * 0.1),
        style = "minimal",
        border = "rounded"
    })
end

-- Register commands
vim.api.nvim_create_user_command("DebugConfig", function()
    M.show_report()
end, { desc = "Show Neovim configuration debug report" })

-- Export functions
M.validate_options = validate_options
M.validate_globals = validate_globals
M.validate_plugins = validate_plugins
M.check_conflicts = check_conflicts

return M 