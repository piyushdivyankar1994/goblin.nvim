-- lua/goblin/htimer.lua
local M = {}

local timer = nil

local defaults = {
    delay = 2000,
    interval = 1800000,
    message = "Time to get a drink",
}

function M.start(opts)
    if timer then
        return -- already running
    end

    opts = vim.tbl_deep_extend("force", defaults, opts or {})

    timer = vim.uv.new_timer()

    timer:start(
        opts.delay, -- delay (ms)
        opts.interval, -- repeat (ms)
        vim.schedule_wrap(function()
            vim.notify("Time to drink some water", vim.log.levels.WARN)
        end)
    )
end

function M.stop()
    if not timer then
        return
    end

    pcall(function()
        timer:stop()
        timer:close()
    end)
    timer = nil
end

return M
