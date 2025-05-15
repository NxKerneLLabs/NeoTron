-- lua/audio.lua
-- Custom audio feedback for Neovim events

local M = {}
local debug = require("core.debug")

-- Paths to sound files (adjust if needed)
M.sound_dir = vim.fn.stdpath("config") .. "/sounds/"
M.sounds = {
  bug = M.sound_dir .. "bug.wav", -- Played on errors or diagnostics
  success = M.sound_dir .. "success.wav", -- Played on success events (e.g., tests passing)
  save = M.sound_dir .. "save.wav", -- Played on file save
}

-- Check if sound files exist and create directory if missing
local function ensure_sound_dir()
  if not vim.loop.fs_stat(M.sound_dir) then
    vim.loop.fs_mkdir(M.sound_dir, 493) -- 493 is 0755 in octal
    debug.info("Created sounds directory: " .. M.sound_dir)
  end
end

-- Play a sound using aplay (common on Linux Mint)
local function play_sound(sound_path)
  if not vim.loop.fs_stat(sound_path) then
    debug.warn("Sound file not found: " .. sound_path)
    return
  end
  -- Use aplay for WAV files (lightweight, pre-installed on most Linux systems)
  local cmd = string.format("aplay %s 2>/dev/null &", vim.fn.shellescape(sound_path))
  vim.fn.system(cmd)
end

-- Public functions to trigger sounds
function M.play_bug()
  debug.info("Playing bug sound for error event")
  play_sound(M.sounds.bug)
end

function M.play_success()
  debug.info("Playing success sound for achievement")
  play_sound(M.sounds.success)
end

function M.play_save()
  debug.info("Playing save sound for file write")
  play_sound(M.sounds.save)
end

-- Initialize audio module
ensure_sound_dir()
debug.info("Audio feedback module initialized")

return M

