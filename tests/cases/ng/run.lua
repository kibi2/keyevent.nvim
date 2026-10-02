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

print("\n")
print("--- CASE : tan tan ta ta tan ---")
common_key.run_sequence(tan_tan_ta_ta_tann)
local events = KeyEvent.get_evcents(2)
print("hold_time = 480 + 130 = ", KeyEvent.hold_time(events[1]))

---@type KeyInfo[]
local meta = {
	{ key = "j", interval = 2000 }, -- tan
	{ key = "<M-j>", interval = 520, keymap = true }, -- repeat 1
	{ key = "J", interval = 170 }, -- repeat 2
	{ key = "<C-j>", interval = 130 }, -- repeat 3
	{ key = "<A-j>", interval = 150 }, -- repeat 4
	{ key = "<D-j>", interval = 300 }, -- tan
	{ key = "<D-j>", interval = 500 }, -- repeat 1 nh = 2
	{ key = "<T-j>", interval = 150 }, -- repeat 2
	{ key = "<T-j>", interval = 280 }, -- ta
	{ key = "j", interval = 320 }, -- ta
	{ key = "J", interval = 300 }, -- tan
	{ key = "<T-j>", interval = 480 }, -- repeat 1 nh = 3
	{ key = "j", interval = 150 }, -- repeat 2
	{ key = "k", interval = 3000 }, -- click k
}

print("\n")
print("--- CASE : tan tan ta ta tan (meta) ---")
common_key.run_sequence(meta)

---@type KeyInfo[]
local diff_key = {
	{ key = "x", interval = 2000 }, -- tan
	{ key = "x", interval = 520, keymap = true }, -- repeat 1
	{ key = "x", interval = 170 }, -- repeat 2
	{ key = "x", interval = 130 }, -- repeat 3
	{ key = "x", interval = 150 }, -- repeat 4
	{ key = "h", interval = 300 }, -- tan h
	{ key = "h", interval = 500 }, -- repeat 1 nh = 2
	{ key = "h", interval = 150 }, -- repeat 2
	{ key = "w", interval = 280 }, -- ta w
	{ key = "e", interval = 320 }, -- ta e
	{ key = "j", interval = 300 }, -- tan j
	{ key = "j", interval = 480 }, -- repeat 1 nh = 3
	{ key = "j", interval = 150 }, -- repeat 2
	{ key = "k", interval = 3000 }, -- click k
}

print("\n")
print("--- CASE : tan tan ta ta tan (diff key) ---")
common_key.run_sequence(diff_key)
