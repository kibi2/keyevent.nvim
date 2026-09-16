local threshold = require("keyevent.threshold")
local log = require("keyevent.log")

local M = {}

--------------------------------------------------
-- default interval (ms)
--------------------------------------------------

---@enum KeyEventSource
local KEY_EVENT_SOURCE = {
    UNDEFINED = "undefined",
    ON_KEY = "on_key",
    KEYMAP = "keymap",
}

---@enum KeyEventType
local KEY_EVENT = {
    CLICK = "click",
    TAP = "tap",
    REPEAT = "repeat",
}

---@enum RawEvent
local RAW_EVENT = {
    CLICK = "click",
    TAP = "tap",
    HOLD_START = "hold_start",
    HOLD_REPEAT = "hold_repeat",
}

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

---@return integer
local function get_time()
    return math.floor(vim.loop.hrtime() / 1e6)
end

local default_event = {
    source = KEY_EVENT_SOURCE.UNDEFINED,
    type = KEY_EVENT.CLICK,
    key = "",
    prev_key = "",
    time = get_time(),
    interval = 0,
    vim_count = 0,
    nt = 0,
    nr = 0,
    hold_start = 0,
}
---@type KeyEvent
local prev_event = vim.deepcopy(default_event)

---@param event KeyEvent
---@return RawEvent
local function get_raw_event(event)
    if event.key ~= event.prev_key then
        return RAW_EVENT.CLICK
    elseif threshold.is_delay(event.interval) then
        return RAW_EVENT.HOLD_START
    elseif threshold.is_interval(event.interval) and event.nr >= 2 then
        return RAW_EVENT.HOLD_REPEAT
    elseif threshold.is_tap(event.interval) then
        return RAW_EVENT.TAP
    else
        return RAW_EVENT.CLICK
    end
end

---@param event KeyEvent
local function set_event_type(event)
    local raw_event = get_raw_event(event)
    if raw_event == RAW_EVENT.CLICK then
        event.type = KEY_EVENT.CLICK
        event.nt = 1
        event.nr = 0
        event.vim_count = vim.v.count
    elseif raw_event == RAW_EVENT.HOLD_START then
        event.type = KEY_EVENT.REPEAT
        event.nr = 2
        event.hold_start = prev_event.time
    elseif raw_event == RAW_EVENT.HOLD_REPEAT then
        event.type = KEY_EVENT.REPEAT
        event.nr = event.nr + 1
    elseif raw_event == RAW_EVENT.TAP then
        event.type = KEY_EVENT.TAP
        event.nt = event.nt + 1
        event.nr = 0
        event.vim_count = vim.v.count
    else
        assert(false, "")
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
local function on_key_event(typed)
    if prev_event.source == KEY_EVENT_SOURCE.KEYMAP and typed == prev_event.key then
        return
    end
    get_event(KEY_EVENT_SOURCE.ON_KEY, typed)
end

---@param typed string
local function on_key(_, typed)
    if #typed == 0 then
        return
    end
    on_key_event(typed)
end

---@param typed string
---@return KeyEvent
function M.keymap_event(typed)
    return get_event(KEY_EVENT_SOURCE.KEYMAP, typed)
end

vim.on_key(on_key)

return M
