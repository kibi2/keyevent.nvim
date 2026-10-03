local common_key = require("common_key")

---@type KeyInfo[]
local meta = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "<M-j>", interval = HOLD + DELTA, keymap = true }, -- repeat 1
	{ key = "J", interval = REPEAT + DELTA }, -- repeat 2
	{ key = "<C-j>", interval = REPEAT - DELTA }, -- repeat 3
	{ key = "<A-j>", interval = REPEAT }, -- repeat 4
	{ key = "<D-j>", interval = TAP - DELTA }, -- tan
	{ key = "<D-j>", interval = HOLD }, -- repeat 1 nh = 2
	{ key = "<T-j>", interval = REPEAT }, -- repeat 2
	{ key = "<T-j>", interval = TAP - DELTA }, -- ta
	{ key = "j", interval = TAP + DELTA }, -- ta
	{ key = "J", interval = TAP }, -- tan
	{ key = "<T-j>", interval = HOLD - DELTA }, -- repeat 1 nh = 3
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "k", interval = CLICK + 50 }, -- click k
}

common_key.run_sequence(meta)
