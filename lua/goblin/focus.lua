-- lua/goblin/focus.lua
local M = {}
local timer = nil
local remaining = 0
local win = nil
local buf = nil
local running = false

local defaults = {
    duration = 25 * 60,
    break_duration = 5 * 60,
    on_focus_end = "Focus session done! Take a break.",
    on_break_end = "Break's over. Back to focus!",
}

local function format_time(secs)
    local mins = math.floor(secs / 60)
    local s = secs % 60
    return string.format("⏱  %d:%02d", mins, s)
end

local function open_float()
    if win and vim.api.nvim_win_is_valid(win) then
        return -- already open, reuse it
    end
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"

    local width = 14
    win = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        width = width,
        height = 1,
        row = 1,
        col = vim.o.columns - width - 2,
        style = "minimal",
        border = "rounded",
        focusable = false,
        zindex = 200,
    })

    vim.wo[win].winhl = "Normal:NormalFloat,FloatBorder:FloatBorder"
end

local function update_float(text)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
    vim.bo[buf].modifiable = false
end

local function close_float()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    win = nil
    buf = nil
end

local function close_timer()
    if timer then
        pcall(function()
            timer:stop()
            timer:close()
        end)
        timer = nil
    end
end

local function tick(opts, is_break)
    remaining = remaining - 1
    update_float(format_time(remaining) .. (is_break and " (break)" or ""))

    if remaining <= 0 then
        close_timer()

        if not running then
            close_float()
            return
        end

        if is_break then
            vim.notify(opts.on_break_end, vim.log.levels.INFO)
            M._begin_phase(opts, false)
        else
            vim.notify(opts.on_focus_end, vim.log.levels.WARN)
            M._begin_phase(opts, true)
        end
    end
end

-- internal: begin a phase (focus or break), reusing the float
function M._begin_phase(opts, is_break)
    remaining = is_break and opts.break_duration or opts.duration

    open_float()
    update_float(format_time(remaining) .. (is_break and " (break)" or ""))

    timer = vim.uv.new_timer()
    timer:start(1000, 1000, vim.schedule_wrap(function()
        tick(opts, is_break)
    end))
end

function M.start(opts)
    if running then
        return
    end
    opts = vim.tbl_deep_extend("force", defaults, opts or {})
    running = true
    vim.notify("Focus session started (" .. (opts.duration / 60) .. " min)", vim.log.levels.INFO)
    M._begin_phase(opts, false)
end

function M.stop()
    running = false
    close_timer()
    close_float()
end

return M
