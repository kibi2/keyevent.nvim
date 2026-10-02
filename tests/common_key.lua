KeyEvent = require("keyevent.keyevent")
local log = require("keyevent.log")

local M = {}

local test_time = 0

---@class KeyInfo
---@field key string
---@field interval integer
---@field keymap boolean|nil

local function advance(ms)
	test_time = test_time + ms
end

local function debug_event(title, event)
	print(title, KeyEvent.to_string(event))
end

---	@param sequence KeyInfo[]
function M.run_sequence(sequence)
	print("PLC src type   (t h  r) key (itv h) seq")
	for _, keyinfo in ipairs(sequence) do
		advance(keyinfo.interval)
		if keyinfo.keymap then
			local event = KeyEvent.keymap_event(keyinfo.key)
			debug_event("MAP", event)
		end
		KeyEvent.on_key_test(keyinfo.key)
	end
end

KeyEvent.setup({
	time = function()
		return test_time
	end,
})

KeyEvent.on_event(function(event)
	debug_event("onk", event)
end)

CLICK = 900
TAP = 300
HOLD = 500
REPEAT = 150
DELTA = 20

return M
