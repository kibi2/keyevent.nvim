local bit = require("bit")
local threshold = require("keyevent.threshold")
local log = require("keyevent.log")

local M = {}

---@enum KeyEventMetaMask
M.KEY_EVENT_META_MASK = {
	S = 1, -- shift
	C = 2, -- ctrl
	A = 4, -- alt
	M = 8, -- meta
	D = 16, -- command / Super
	T = 32, -- Meta（Altではない場合）
}

---@type {integer:string}
M.KEY_EVENT_META_CHAR = {}
for key, mask in pairs(M.KEY_EVENT_META_MASK) do
	M.KEY_EVENT_META_CHAR[mask] = key
end

---@enum KeyEventSource
M.KEY_EVENT_SOURCE = {
	ON_KEY = "on_key",
	KEYMAP = "keymap",
}

---@enum KeyEventType
M.KEY_EVENT_TYPE = {
	CLICK = "click",
	TAP = "tap",
	REPEAT = "repeat",
	REPEAT_END = "repeat_end",
}

---@enum KeyEventState
local STATE = {
	NORMAL = "normal",
	HOLD = "hold",
	REPEAT = "repeat",
}

local SMALL_TIME = 10

local callbacks = {}

---@class KeyEvent
---@field source KeyEventSource
---@field type KeyEventType
---@field ng_repeat boolean
---@field key string
---@field prev_key string
---@field meta integer
---@field prev_meta integer
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
local START_EVENT = {
	source = M.KEY_EVENT_SOURCE.ON_KEY,
	type = M.KEY_EVENT_TYPE.CLICK,
	ng_repeat = false,
	key = "",
	prev_key = "",
	meta = 0,
	prev_meta = 0,
	time = get_time(),
	interval = 0,
	nt = 0,
	nr = 0,
	hold_start = 0,
}
---@type KeyEvent[]
local event_hist = { START_EVENT, START_EVENT }
---@type KeyEventState
local state = STATE.NORMAL
local repeat_timer = vim.loop.new_timer()

---@param event KeyEvent|nil
local function emit(event)
	if not event then
		return
	end
	for _, callback in ipairs(callbacks) do
		callback(event)
	end
	log.probe(M.to_string(event))
end

local function stop_repeat_timer()
	repeat_timer:stop()
end

local function close_repeat_timer()
	if not repeat_timer:is_closing() then
		repeat_timer:stop()
		repeat_timer:close()
	end
end

local function start_repeat_timer()
	repeat_timer:stop()
	repeat_timer:start(
		threshold.get_repeat_time(),
		0,
		vim.schedule_wrap(function()
			if state ~= STATE.REPEAT then
				return
			end
			state = STATE.NORMAL
			local event = vim.deepcopy(event_hist[2])
			event.soruce = M.KEY_EVENT_SOURCE.ON_KEY
			event.type = M.KEY_EVENT_TYPE.REPEAT_END
			event.time = get_time()
			event.interval = event.time - event_hist[2].time
			emit(event)
		end)
	)
end

-- EVENT:
--  D:is different key
--  H:is_hold, R: is_repeat, T:is_tap
--  C:other
--  | STATE | transition | stay |
--  | NORMAL | H -> HOLD | TCD<br>R:NG |
--  | HOLD | R -> REPEAT<br>TCD -> NORMAL | H |
--  | REPEAT | TCD(H) -> NORMAL | R |
---@param event KeyEvent
local function transition(event)
	if not M.is_same_key(event) then --  D:is different key
		state = STATE.NORMAL
		return
	end
	if state == STATE.NORMAL then
		if threshold.is_hold(event.interval) then
			state = STATE.HOLD
		end
	elseif state == STATE.HOLD then
		if threshold.is_repeat(event.interval) then
			state = STATE.REPEAT
		elseif not threshold.is_hold(event.interval) then
			state = STATE.NORMAL
		end
	elseif state == STATE.REPEAT then
		if not threshold.is_repeat(event.interval) then
			state = STATE.NORMAL
		end
	else
		error("invalid state: " .. tostring(state))
	end
end

---@param prev_event KeyEvent
---@param event KeyEvent
local function process_normal(prev_event, event)
	if threshold.is_tap(event.interval) then
		event.type = M.KEY_EVENT_TYPE.TAP
	else
		event.type = M.KEY_EVENT_TYPE.CLICK
	end
	event.ng_repeat = threshold.is_repeat(event.interval)
	if prev_event.type == M.KEY_EVENT_TYPE.REPEAT then
		event.nt = 1
	elseif not M.is_same_key(event) then
		event.nt = 1
	elseif event.type == M.KEY_EVENT_TYPE.TAP then
		event.nt = event.nt + 1
	else
		event.nt = 1
	end
	event.hold_start = 0
	event.nr = 0
end

---@param prev_event KeyEvent
---@param event KeyEvent
local function process_hold(prev_event, event)
	event.type = M.KEY_EVENT_TYPE.REPEAT
	event.ng_repeat = false
	event.hold_start = prev_event.time
	event.nr = 1
end

---@param event KeyEvent
local function process_repeat(event)
	event.type = M.KEY_EVENT_TYPE.REPEAT
	event.ng_repeat = false
	event.nr = event.nr + 1
end

---@param prev_event KeyEvent
---@param event KeyEvent
local function process_event(prev_event, event)
	transition(event)
	if state == STATE.NORMAL then
		process_normal(prev_event, event)
	elseif state == STATE.HOLD then
		process_hold(prev_event, event)
	else
		process_repeat(event)
	end
	if event.type == M.KEY_EVENT_TYPE.REPEAT then
		start_repeat_timer()
	else
		stop_repeat_timer()
	end
end

---@param prev_event KeyEvent
---@param key_notation string
---@return KeyEvent
local function get_event(prev_event, key_notation)
	local key, meta = M.parse(key_notation)
	local event = vim.deepcopy(prev_event)
	event.key = key
	event.prev_key = prev_event.key
	event.meta = meta
	event.prev_meta = prev_event.meta
	event.time = get_time()
	event.interval = event.time - prev_event.time
	return event
end

---@param event KeyEvent
local function push_event(event)
	event_hist[1] = event_hist[2]
	event_hist[2] = vim.deepcopy(event)
	emit(event)
end

---@param typed string
local function on_key_event(typed)
	local key = vim.fn.keytrans(typed)
	if get_time() - event_hist[2].time <= SMALL_TIME then
		return
	end
	local event = get_event(event_hist[2], key)
	event.source = M.KEY_EVENT_SOURCE.ON_KEY
	process_event(event_hist[2], event)
	push_event(event)
end

---@param typed string
local function on_key(_, typed)
	if #typed == 0 then
		return
	end
	on_key_event(typed)
end

---@param key string
---@param meta integer
---@return string
local function key_note(key, meta)
	local note = M.unparse(key, meta)
	if not note then
		return string.format("%d-%s", meta, key)
	end
	return note:match("^<(.+)>$") or note
end

local META_MASK = M.KEY_EVENT_META_MASK

---Parse a key notation into key and meta mask.
---@param key_notation string
---@return string key
---@return integer meta
function M.parse(key_notation)
	-- 1 character
	if #key_notation == 1 then
		if key_notation:match("%u") then
			return key_notation:lower(), META_MASK.S
		end
		return key_notation, 0
	end
	-- <X>
	local key = key_notation:match("^<(.+)>$")
	if not key then
		return key_notation, 0
	end
	-- <X>: X is one character
	if #key == 1 then
		if key:match("%u") then
			return key:lower(), META_MASK.S
		end
		return key, 0
	end
	-- <M1-M2-...-Key>
	local parts = {}
	for part in key:gmatch("[^-]+") do
		parts[#parts + 1] = part
	end
	-- Need at least one meta and one key.
	if #parts < 2 then
		return key_notation, 0
	end
	local meta = 0
	for i = 1, #parts - 1 do
		local mask = META_MASK[parts[i]:upper()]
		if not mask then
			return key_notation, 0
		end
		meta = M.set_on(meta, mask)
	end
	-- The last part is the key.
	-- The key itself is not interpreted as Shift.
	-- <C-J> means Ctrl+j, not Ctrl+Shift+j.
	local last = parts[#parts]:lower()
	return last, meta
end

---Unparse a key and meta mask into a canonical key notation.
---@param key string
---@param meta integer
---@return string?
function M.unparse(key, meta)
	-- Only a single character can be represented.
	if #key ~= 1 then
		return nil
	end
	-- Uppercase key implies Shift.
	if key:match("%u") then
		meta = M.set_on(meta, META_MASK.S)
	end
	key = key:lower()
	local chars = {}
	-- Fixed order: S-C-A-M-D-T
	local masks = {
		META_MASK.S,
		META_MASK.C,
		META_MASK.A,
		META_MASK.M,
		META_MASK.D,
		META_MASK.T,
	}
	for _, mask in ipairs(masks) do
		if M.is_on(meta, mask) then
			chars[#chars + 1] = M.KEY_EVENT_META_CHAR[mask]
		end
	end
	chars[#chars + 1] = key
	return "<" .. table.concat(chars, "-") .. ">"
end

---@param event KeyEvent
---@return string
function M.to_string(event)
	return string.format(
		"%s\t%s\t:(%s, %s), [%d %d]\t%s [%d, %d]",
		event.source,
		event.type,
		key_note(event.prev_key, event.prev_meta),
		key_note(event.key, event.meta),
		event.nt,
		event.nr,
		event.ng_repeat and "NG" or "",
		event.interval,
		M.hold_time(event)
	)
end

---@param key_notation string
---@return KeyEvent
function M.keymap_event(key_notation)
	local time = get_time()
	local prev_event = event_hist[2]
	if time - prev_event.time <= SMALL_TIME then
		prev_event = event_hist[1]
	end
	local event = get_event(prev_event, key_notation)
	event.source = M.KEY_EVENT_SOURCE.KEYMAP
	process_event(prev_event, event)
	if prev_event == event_hist[2] then
		push_event(event)
	end
	return event
end

---@param event KeyEvent
---@return boolean
function M.is_same_key(event)
	return event.key == event.prev_key
end

---@param notation1 string
---@param notation2 string
---@return boolean
function M.is_same_key_notation(notation1, notation2)
	local key_1, meta_1 = M.parse(notation1)
	local key_2, meta_2 = M.parse(notation2)
	return key_1 == key_2 and meta_1 == meta_2
end

---@param event KeyEvent
---@return integer
function M.hold_time(event)
	if event.type ~= M.KEY_EVENT_TYPE.REPEAT then
		return 0
	end
	return event.time - event.hold_start
end

---@param value integer
---@param mask integer
---@return boolean
function M.is_on(value, mask)
	return bit.band(value, mask) == mask
end

---@param value integer
---@param mask integer
---@return boolean
function M.is_off(value, mask)
	return bit.band(value, mask) == 0
end

---@param value integer
---@param mask_on integer
---@param mask_off integer
---@return boolean
function M.is_on_off(value, mask_on, mask_off)
	return M.is_on(value, mask_on) and M.is_off(value, mask_off)
end

---@param value integer
---@param mask integer
---@return integer
function M.set_on(value, mask)
	return bit.bor(value, mask)
end

---@param value integer
---@param mask integer
---@return integer
function M.set_off(value, mask)
	return bit.band(value, bit.bnot(mask))
end

function M.on_event(callback)
	callbacks[#callbacks + 1] = callback
end

---@param mode string|string[]
---@param lhs string
---@param tap integer
---@param rep integer
---@param rhs string
function M.set(mode, lhs, tap, rep, rhs)
	vim.keymap.set(mode, lhs, function()
		local event = M.keymap_event(lhs)
		log.probe(M.to_string(event))
		if event.nt == tap then
			if event.nr == rep then
				return rhs
			elseif event.nr > rep then
				return nil
			end
		end
		return lhs
	end, { expr = true })
end

vim.on_key(on_key)

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = close_repeat_timer,
})

return M
