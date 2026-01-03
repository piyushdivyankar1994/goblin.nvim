-- lua/goblin/htimer.lua
local Timer = require("plenary.timer")

local M = {}

local timer = nil

function M.start()
  if timer then
    return -- already running
  end

  timer = Timer:new()

  timer:start(
    2000,  -- delay (ms)
    2000,  -- repeat (ms)
    vim.schedule_wrap(function()
      print("hello world")
    end)
  )
end

function M.stop()
  if not timer then
    return
  end

  timer:stop()
  timer:close()
  timer = nil
end

return M
