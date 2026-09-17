local threshold = require("keyevent.threshold")
local log = require("keyevent.log")

local M = {}

---@enum KeyEventSource
M.KEY_EVENT_SOURCE = {
	ON_KEY = "on_key",
	KEYMAP = "keymap",
}

---@enum KeyEventType
M.KEY_EVENT = {
	CLICK = "click",
	TAP = "tap",
	REPEAT = "repeat",
}

---@enum KeyEventState
local STATE = {
	HOLD = "hold",
	NO_HOLD = "no_hold",
}

---@class KeyEvent
---@field source KeyEventSource
---@field type KeyEventType
---@field ng_repeat boolean
---@field key string
---@field prev_key string
---@field time integer
---@field interval integer
---@field nt integer
---@field nr integer
---@field hold_start integer

---@return integer
local function get_time()
	return math.floor(vim.loop.hrtime() / 1e6)
end

---@type KeyEvent
local start_event = {
	source = M.KEY_EVENT_SOURCE.ON_KEY,
	type = M.KEY_EVENT.CLICK,
	ng_repeat = false,
	key = "",
	prev_key = "",
	time = get_time(),
	interval = 0,
	nt = 0,
	nr = 0,
	hold_start = 0,
}
---@type KeyEvent
local prev_event = vim.deepcopy(start_event)
---@type KeyEventState
local state = STATE.NO_HOLD

---@param event KeyEvent
local function process_no_hold(event)
	if threshold.is_tap(event.interval) then
		event.type = M.KEY_EVENT.TAP
	else
		event.type = M.KEY_EVENT.CLICK
	end
	event.ng_repeat = threshold.is_repeat(event.interval)
	if prev_event.type == M.KEY_EVENT.REPEAT then
		event.nt = 1
	elseif M.is_same_key(event) and event.type == M.KEY_EVENT.TAP then
		event.nt = event.nt + 1
	else
		event.nt = 1
	end
	event.nr = 0
	event.hold_start = 0
end

---@param event KeyEvent
local function process_hold(event)
	event.type = M.KEY_EVENT.REPEAT
	event.ng_repeat = false
	if event.nr == 0 then
		event.hold_start = prev_event.time
	end
	event.nr = event.nr + 1
end

local function transition(event)
	if state == STATE.NO_HOLD then
		if M.is_same_key(event) and threshold.is_hold(event.interval) then
			state = STATE.HOLD
		end
	else
		if
			not (M.is_same_key(event) and threshold.is_repeat(event.interval))
		then
			state = STATE.NO_HOLD
		end
	end
end

---@param event KeyEvent
local function process_event(event)
	transition(event)
	if state == STATE.NO_HOLD then
		process_no_hold(event)
	else
		process_hold(event)
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
	process_event(event)
	return event
end

---@param typed string
local function on_key_event(typed)
	if
		prev_event.source == M.KEY_EVENT_SOURCE.KEYMAP
		and typed == prev_event.key
	then
		return
	end
	if get_time() - prev_event.time <= 10 then
		return
	end
	local event = get_event(M.KEY_EVENT_SOURCE.ON_KEY, typed)
	prev_event = vim.deepcopy(event)
end

---@param typed string
local function on_key(_, typed)
	if #typed == 0 then
		return
	end
	on_key_event(typed)
end

---@param event KeyEvent
---@return string
function M.to_string(event)
	return string.format(
		"%s\t%s\t:(%s, %s), [%d %d]\t%s [%d, %d]",
		event.source,
		event.type,
		event.prev_key,
		event.key,
		event.nt,
		event.nr,
		event.ng_repeat and "NG" or "",
		event.interval,
		M.hold_time(event)
	)
end

---@param typed string
---@return KeyEvent
function M.keymap_event(typed)
	local event = get_event(M.KEY_EVENT_SOURCE.KEYMAP, typed)
	prev_event = vim.deepcopy(event)
	return event
end

---@param event KeyEvent
---@return boolean
function M.is_same_key(event)
	return event.key == event.prev_key
end

---@param event KeyEvent
---@return integer
function M.hold_time(event)
	if event.type ~= M.KEY_EVENT.REPEAT then
		return 0
	end
	return event.time - event.hold_start
end

vim.on_key(on_key)

return M
