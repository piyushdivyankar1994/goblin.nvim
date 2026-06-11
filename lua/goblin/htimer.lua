-- lua/goblin/htimer.lua
local M = {}

local timers = {}

local defaults = {
    delay = 2000,
    interval = 1800000,
    message = "Time to get a drink",
}

function M.start(name, opts)
    name = name or "default"
    if timers[name] then
        return -- already running
    end

    opts = vim.tbl_deep_extend("force", defaults, opts or {})

    local timer = vim.uv.new_timer()

    timer:start(
        opts.delay,    -- delay (ms)
        opts.interval, -- repeat (ms)
        vim.schedule_wrap(function()
            vim.notify("Time to drink some water", vim.log.levels.WARN, { title = "Goblin Timer" })
        end)
    )
    timers[name] = timer
end

function M.stop(name)
    name = name or "default"
    if not timers[name] then
        return
    end

    pcall(function()
        timers[name]:stop()
        timers[name]:close()
    end)
    timers[name] = nil
end

function M.stop_all()
    for name in pairs(timers) do
        M.stop(name)
    end
end

function M.list()
    local names = {}
    for name in pairs(timers) do
        table.insert(names, name)
    end
    return names
end

return M
