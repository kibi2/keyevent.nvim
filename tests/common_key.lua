KeyEvent = require("keyevent.keyevent")
Config = require("keyevent.config")
Os = require("keyevent.os")

local M = {}

local test_time = 0

---@class KeyInfo
---@field key string
---@field interval integer
---@field keymap boolean|nil

local function debug_event(title, event)
	print(title, KeyEvent.to_string(event))
end

function M.advance(ms)
	test_time = test_time + ms
end

---	@param sequence KeyInfo[]
function M.run_sequence(sequence)
	print("PLC src type   (t h  r) key (itv h) seq")
	for _, keyinfo in ipairs(sequence) do
		M.advance(keyinfo.interval)
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

require("keyevent").on_event(function(event)
	debug_event("onk", event)
end)

CLICK = 900
TAP = 300
HOLD = 500
REPEAT = 150
DELTA = 20

if not Config.threshold.delay then
	Config.threshold.delay = HOLD
	Config.threshold.interval = REPEAT
end

return M
