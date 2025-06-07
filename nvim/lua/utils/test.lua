-- nvim/lua/utils/test.lua
local debug = require("core.debug.logger")

debug.info("[TEST] Test module loaded successfully.")

-- Simulate a failure
local function simulate_failure()
  debug.error("[TEST] Simulated error in test module.")
  return nil, "Simulated error"
end

-- Run the test
local ok, err = simulate_failure()
if not ok then
  debug.error("[TEST] Test failed: " .. tostring(err))
end

return {
  ok = ok,
  error = err
} 