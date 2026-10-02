local common_key = require("common_key")

---@type KeyInfo[]
local tap_tap_normal = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tap_tap_normal)

---@type KeyInfo[]
local tap_tap_ng1 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tap_tap_ng1)

---@type KeyInfo[]
local tap_tap_ng2 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = TAP }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tap_tap_ng2)

---@type KeyInfo[]
local tap_tap_ng3 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = TAP }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tap_tap_ng3)
