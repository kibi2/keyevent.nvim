local common_key = require("common_key")

---@type KeyInfo[]
local tan_repeat_normal = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tan_repeat_normal)

---@type KeyInfo[]
local tan_repeat_ng1 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = REPEAT }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tan_repeat_ng1)

---@type KeyInfo[]
local tan_repeat_ng2 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = REPEAT }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tan_repeat_ng2)
