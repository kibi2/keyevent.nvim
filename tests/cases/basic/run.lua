local root = assert(os.getenv("KIBI2_REPO_ROOT"))
package.path = root .. "/tests/?.lua;" .. package.path
local common_key = require("common_key")

---@type KeyInfo[]
local tan_tan_ta_ta_tann = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = HOLD, keymap = true }, -- repeat 1
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
}

print("\n")
print("--- CASE : tan tan ta ta tan ---")
common_key.run_sequence(tan_tan_ta_ta_tann)
local events = KeyEvent.get_evcents(2)
print("hold_time = 500 + 150 = ", KeyEvent.hold_time(events[1]))

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

print("\n")
print("--- CASE : tan tan ta ta tan (meta) ---")
common_key.run_sequence(meta)

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

print("\n")
print("--- CASE : tan tan ta ta tan (diff key) ---")
common_key.run_sequence(diff_key)
