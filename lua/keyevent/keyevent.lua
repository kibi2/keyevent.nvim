local analyzer = require("keyevent.analyzer")
local threshold = require("keyevent.threshold")
local history = require("keyevent.history")
local bitflag = require("keyevent.bitflag")
local log = require("keyevent.log")

local M = {}

---@enum KeyEventMetaMask
local META = {
	S = 1, -- shift
	C = 2, -- ctrl
	A = 4, -- alt
	M = 8, -- meta
	D = 16, -- command / Super
	T = 32, -- Meta(not Alt)
}

---@type {integer:string}
local META_CHAR = {}
for key, mask in pairs(META) do
	META_CHAR[mask] = key
end

---@enum KeyEventSource
M.KEY_EVENT_SOURCE = {
	ON_KEY = "onk",
	KEYMAP = "map",
}

---@enum KeyEventType
M.KEY_EVENT_TYPE = {
	CLICK = "click",
	TAP = "tap",
	REPEAT = "repeat",
	REPEAT_END = "re_end",
	BREAK = "BREAK", -- The key event sequence was interrupted by a buffer switch.
}

---@enum KeyEventState
local STATE = {
	NORMAL = "normal",
	HOLD = "hold",
	REPEAT = "repeat",
}

local callbacks = {}

---@class KeyEvent
---@field source KeyEventSource
---@field bufnr integer
---@field type KeyEventType
---@field ng_repeat integer
---@field key string
---@field prev_key string
---@field meta integer
---@field prev_meta integer
---@field time integer
---@field interval integer
---@field nt integer
---@field nr integer
---@field nh integer
---@field hold_start integer

---@return integer
local default_time = function()
	return math.floor(vim.loop.hrtime() / 1e6)
end

local time = default_time

---@type KeyEvent
local START_EVENT = {
	source = M.KEY_EVENT_SOURCE.ON_KEY,
	bufnr = -1,
	type = M.KEY_EVENT_TYPE.CLICK,
	ng_repeat = 0,
	key = "",
	prev_key = "",
	meta = 0,
	prev_meta = 0,
	time = time(),
	interval = 0,
	nt = 0,
	nr = 0,
	nh = 0,
	hold_start = 0,
}
---@type KeyEvent
local prev_event = START_EVENT
---@type KeyEventState
local state = STATE.NORMAL
local repeat_timer = vim.loop.new_timer()

---@param event KeyEvent|nil
local function emit(event)
	if not event then
		return
	end
	local event_break
	if event.bufnr ~= prev_event.bufnr and prev_event.bufnr ~= -1 then
		log.watch(event.source, "emit:BREAK")
		event_break = vim.deepcopy(prev_event)
		event_break.type = M.KEY_EVENT_TYPE.BREAK
	end
	for _, callback in ipairs(callbacks) do
		if event_break then
			callback(event_break)
		end
		callback(event)
	end
	-- log.watch(event.source, "emit:" .. M.to_string(event))
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
			local event = vim.deepcopy(prev_event)
			event.source = M.KEY_EVENT_SOURCE.ON_KEY
			event.type = M.KEY_EVENT_TYPE.REPEAT_END
			event.time = time()
			event.interval = event.time - prev_event.time
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

---@param event KeyEvent
local function set_ng_repeat(event)
	if not M.is_same_key(event) then
		event.ng_repeat = 0
	elseif threshold.is_repeat(event.interval) then
		event.ng_repeat = event.ng_repeat + 1
	else
		event.ng_repeat = 0
	end
end

---@param event KeyEvent
local function process_normal(event)
	if threshold.is_tap(event.interval) then
		event.type = M.KEY_EVENT_TYPE.TAP
	else
		event.type = M.KEY_EVENT_TYPE.CLICK
		event.nh = 0
	end
	set_ng_repeat(event)
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

---@param event KeyEvent
local function process_hold(event)
	event.type = M.KEY_EVENT_TYPE.REPEAT
	event.ng_repeat = 0
	event.hold_start = prev_event.time
	event.nr = 1
	event.nh = event.nh + 1
end

---@param event KeyEvent
local function process_repeat(event)
	event.type = M.KEY_EVENT_TYPE.REPEAT
	event.ng_repeat = 0
	event.nr = event.nr + 1
end

---@param event KeyEvent
local function process_event(event)
	transition(event)
	if state == STATE.NORMAL then
		process_normal(event)
	elseif state == STATE.HOLD then
		process_hold(event)
	else
		process_repeat(event)
	end
	if event.type == M.KEY_EVENT_TYPE.REPEAT then
		start_repeat_timer()
	else
		stop_repeat_timer()
	end
end

---@param key_notation string
---@return KeyEvent
local function get_event(key_notation)
	local key, meta = M.parse(key_notation)
	local event = vim.deepcopy(prev_event)
	event.bufnr = vim.api.nvim_get_current_buf()
	event.key = key
	event.prev_key = prev_event.key
	event.meta = meta
	event.prev_meta = prev_event.meta
	event.time = time()
	event.interval = event.time - prev_event.time
	return event
end

---@param event KeyEvent
local function push(event)
	local prev = history.peek()
	if event.type == M.KEY_EVENT_TYPE.REPEAT and event.type == prev.type then
		history.reset(vim.deepcopy(event))
	else
		history.push(vim.deepcopy(event))
	end
end

---@param event KeyEvent
local function push_event(event)
	push(vim.deepcopy(event))
	emit(event)
	prev_event = vim.deepcopy(event)
end

---@param key string
local function on_key_event(key)
	local is_dup = time() - prev_event.time <= vim.o.ttimeoutlen
	if is_dup then
		if history.peek().key == "<Esc>" and #key == 1 then
			history.peek().key = string.format("<A-%s>", key)
			emit(history.peek())
		end
		return
	end
	local event = get_event(key)
	event.source = M.KEY_EVENT_SOURCE.ON_KEY
	process_event(event)
	push_event(event)
end

---@param typed string
local function on_key(_, typed)
	if #typed == 0 then
		return
	end
	on_key_event(vim.fn.keytrans(typed))
end

---@param key string
---@param meta integer
---@return string
local function key_note(key, meta)
	local note = M.unparse(key, meta)
	if not note then
		if meta == 0 then
			return string.format("%s", key)
		else
			return string.format("%d-%s", meta, key)
		end
	else
		return note:match("^<(.+)>$") or note
	end
end

function M.meta()
	return META
end

---Parse a key notation into key and meta mask.
---@param key_notation string
---@return string key
---@return integer meta
function M.parse(key_notation)
	-- 1 character
	if #key_notation == 1 then
		if key_notation:match("%u") then
			return key_notation:lower(), META.S
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
			return key:lower(), META.S
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
		local mask = META[parts[i]:upper()]
		if not mask then
			return key_notation, 0
		end
		meta = bitflag.set_on(meta, mask)
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
		meta = bitflag.set_on(meta, META.S)
	end
	key = key:lower()
	local chars = {}
	-- Fixed order: S-C-A-M-D-T
	local masks = {
		META.S,
		META.C,
		META.A,
		META.M,
		META.D,
		META.T,
	}
	for _, mask in ipairs(masks) do
		if bitflag.is_on(meta, mask) then
			chars[#chars + 1] = META_CHAR[mask]
		end
	end
	chars[#chars + 1] = key
	return "<" .. table.concat(chars, "-") .. ">"
end

---@param event KeyEvent
---@return string
function M.to_string(event)
	local ng_repeat
	if event.ng_repeat == 0 then
		ng_repeat = ""
	else
		ng_repeat = event.ng_repeat .. "-"
	end
	return string.format(
		"%s %-6s (%d %d %2d) %3s (%3d %d) %s",
		event.source,
		ng_repeat .. event.type,
		event.nt,
		event.nh,
		event.nr,
		key_note(event.key, event.meta),
		event.interval,
		math.floor(M.hold_time(event) / 1000),
		M.keys(10)
	)
end

---@param key_notation string
---@return KeyEvent
function M.keymap_event(key_notation)
	local is_dup = time() - prev_event.time <= vim.o.ttimeoutlen
	local event = get_event(key_notation)
	if is_dup and M.is_same_key(event) then
		return prev_event
	end
	event.source = M.KEY_EVENT_SOURCE.KEYMAP
	process_event(event)
	push_event(event)
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

function M.on_event(callback)
	callbacks[#callbacks + 1] = callback
end

---@param count integer
---@return  KeyEvent[]
function M.get_evcents(count)
	---@type KeyEvent[]
	local seq = {}
	for index = 1, count do
		seq[#seq + 1] = history.peek(index)
	end
	return seq
end

---@param count integer
---@return  string
function M.keys(count)
	local seq = {}
	for _, event in ipairs(M.get_evcents(count)) do
		if event.key then
			local note = M.unparse(event.key, event.meta) or ""
			note = note:match("^<(.)>$") or note
			if event.type == M.KEY_EVENT_TYPE.REPEAT then
				note = string.format("↻")
			end
			seq[#seq + 1] = note
			if event.type == M.KEY_EVENT_TYPE.CLICK then
				break
			end
		end
	end
	local reversed = {}
	for index = #seq, 1, -1 do
		reversed[#reversed + 1] = seq[index]
	end
	return table.concat(reversed)
end

---@param index integer
---@return KeyEvent
function M.peek(index)
	return history.peek(index)
end

M.on_key_test = function(key)
	on_key_event(key)
end

function M.setup(opts)
	opts = opts or {}
	time = opts.time or default_time
	prev_event.time = time()
end

vim.on_key(on_key)
M.on_event(analyzer.on_event)

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = close_repeat_timer,
})

return M
