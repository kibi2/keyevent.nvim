local root = assert(os.getenv("KIBI2_REPO_ROOT"))
package.path = root .. "/tests/?.lua;" .. package.path
local common_key = require("common_key")

---@type KeyInfo[]
local tan_tan_ta_ta_tann = {
	{ key = "j", interval = 2000 }, -- tan
	{ key = "j", interval = 520, keymap = true }, -- repeat 1
	{ key = "j", interval = 170 }, -- repeat 2
	{ key = "j", interval = 130 }, -- repeat 3
	{ key = "j", interval = 150 }, -- repeat 4
	{ key = "j", interval = 300 }, -- tan
	{ key = "j", interval = 500 }, -- repeat 1 nh = 2
	{ key = "j", interval = 150 }, -- repeat 2
	{ key = "j", interval = 280 }, -- ta
	{ key = "j", interval = 320 }, -- ta
	{ key = "j", interval = 300 }, -- tan
	{ key = "j", interval = 480 }, -- repeat 1 nh = 3
	{ key = "j", interval = 150 }, -- repeat 2
}

print("--- CASE : tan tan ta ta tan ---")
common_key.run_sequence(tan_tan_ta_ta_tann)
local events = KeyEvent.get_evcents(2)
print("hold_time = 480 + 130 = ", KeyEvent.hold_time(events[1]))

---@type KeyInfo[]
local ng_repeat = {
	{ key = "j", interval = 1000 }, -- ta
	{ key = "j", interval = 479 }, -- ta
	{ key = "j", interval = 520 }, -- tan
	{ key = "j", interval = 130 }, -- repeat
	{ key = "j", interval = 171 }, -- ta (miss)
	{ key = "j", interval = 150 }, -- ng repeat
}

print("\n--- CASE : ng ---")
common_key.run_sequence(ng_repeat)

---@type KeyInfo[]
local ng_hold = {
	{ key = "j", interval = 1000 }, -- ta
	{ key = "j", interval = 500 }, -- tan
	{ key = "j", interval = 500 }, -- tan
	{ key = "j", interval = 150 }, -- repeat
	{ key = "j", interval = 500 }, -- tan
	{ key = "j", interval = 500 }, -- tan
	{ key = "j", interval = 150 }, -- repeat
}

print("\n--- CASE : ng ---")
common_key.run_sequence(ng_hold)
