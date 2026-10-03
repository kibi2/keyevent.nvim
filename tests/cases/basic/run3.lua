local common_key = require("common_key")

---@type KeyInfo[]
local diff_key = {
	{ key = "x", interval = CLICK }, -- tan
	{ key = "x", interval = HOLD, keymap = true }, -- repeat 1
	{ key = "x", interval = REPEAT }, -- repeat 2
	{ key = "x", interval = REPEAT }, -- repeat 3
	{ key = "x", interval = REPEAT }, -- repeat 4
	{ key = "h", interval = TAP }, -- tan h
	{ key = "h", interval = HOLD }, -- repeat 1 nh = 2
	{ key = "h", interval = REPEAT }, -- repeat 2
	{ key = "w", interval = TAP }, -- ta w
	{ key = "e", interval = TAP }, -- ta e
	{ key = "j", interval = TAP }, -- tan j
	{ key = "j", interval = HOLD }, -- repeat 1 nh = 3
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "k", interval = CLICK }, -- click k
}

common_key.run_sequence(diff_key)
