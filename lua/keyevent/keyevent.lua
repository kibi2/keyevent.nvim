local log = require("keyevent.log")

local M = {}

--------------------------------------------------
-- default interval (ms)
--------------------------------------------------

local interval = {
    rep1 = 78,
    rep2 = 91,
    hold1 = 490,
    hold2 = 510,
    tap = 1000,
}

---@alias KeyEventType
---| "click"
---| "tap"
---| "repeat"
---| "hold_end"

---@class KeyEvent
---@field source KeyEventSource
---@field type KeyEventType
---@field key string
---@field time integer
---@field prev_key string
---@field vim_count integer
---@field interval integer
---@field nt integer
---@field nr integer
---@field hold_start integer

---@alias KeyEventSource
---| "on_key"
---| "keymap"

local function get_time()
    return math.floor(vim.loop.hrtime() / 1e6)
end

local default_event = {
    source = "",
    type = "click",
    key = "",
    prev_key = "",
    time = get_time(),
    interval = 0,
    vim_count = 0,
    nt = 0,
    nr = 0,
    hold_start = 0,
}
local prev_event = vim.deepcopy(default_event)

---@param event KeyEvent
local function set_event_type(event)
    if event.key ~= event.prev_key then
        event.type = "click"
        event.nt = 1
        event.nr = 0
        event.vim_count = vim.v.count
    elseif interval.hold1 <= event.interval and event.interval <= interval.hold2 then
        event.type = "repeat"
        event.nr = 2
        event.hold_start = prev_event.time
    elseif interval.rep1 <= event.interval and event.interval <= interval.rep2 and event.nr >= 2 then
        event.type = "repeat"
        event.nr = event.nr + 1
    elseif event.interval <= interval.tap then
        event.type = "tap"
        event.nt = event.nt + 1
        event.nr = 0
        event.vim_count = vim.v.count
    else
        event.type = "click"
        event.nt = 1
        event.nr = 0
        event.vim_count = vim.v.count
    end
end

---@param source KeyEventSource
---@param typed string
---@return KeyEvent
local function get_event(source, typed)
    local event = vim.deepcopy(prev_event)
    event.source = source
    event.key = typed
    event.prev_key = prev_event.key
    event.time = get_time()
    event.interval = event.time - prev_event.time
    set_event_type(event)
    prev_event = vim.deepcopy(event)
    log.debug(
        "%s\t%s\t:(%s) %d, [%d %d]\t[%d]",
        event.source,
        event.type,
        event.key,
        event.vim_count,
        event.nt,
        event.nr,
        event.interval
    )
    return event
end

---@param typed string
---@return KeyEvent
function M.on_key_event(typed)
    return get_event("on_key", typed)
end

---@param typed string
---@return KeyEvent
function M.keymap_event(typed)
    return get_event("keymap", typed)
end

return M
