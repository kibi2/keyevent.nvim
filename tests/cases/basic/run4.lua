local common_key = require("common_key")

DELTA = 10
TAP = 100
HOLD = 200
REPEAT = 300

local opts = {
	threshold = {
		delta = DELTA,
		tap = TAP,
		delay = HOLD,
		interval = REPEAT,
	},
}

require("keyevent").setup(opts)
---@type KeyInfo[]
local tan_tan_ta_ta_tann = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = HOLD }, -- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
	{ key = "j", interval = TAP }, -- tan
	{ key = "j", interval = HOLD }, -- repeat 1 nh = 2
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = TAP }, -- ta
	{ key = "j", interval = TAP }, -- ta
	{ key = "j", interval = TAP }, -- tan
	{ key = "j", interval = HOLD }, -- repeat 1 nh = 3
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
	{ key = "j", interval = REPEAT }, -- repeat 5
	{ key = "j", interval = REPEAT }, -- repeat 6
	{ key = "j", interval = REPEAT }, -- repeat 7
	{ key = "j", interval = REPEAT + DELTA + 1 }, -- repeat 7
}

common_key.run_sequence(tan_tan_ta_ta_tann)
