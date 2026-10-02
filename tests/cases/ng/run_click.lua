local common_key = require("common_key")

---@type KeyInfo[]
local tan_click_normal = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tan_click_normal)

---@type KeyInfo[]
local tan_click_ng1 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = CLICK }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tan_click_ng1)

---@type KeyInfo[]
local tan_click_ng2 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = CLICK }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tan_click_ng2)

---@type KeyInfo[]
local tan_click_ng3 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = CLICK }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tan_click_ng3)

---@type KeyInfo[]
local tan_click_ng4 = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = TAP }, --- repeat 1
	{ key = "j", interval = HOLD }, --- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = CLICK }, -- repeat 3
	{ key = "j", interval = REPEAT }, -- repeat 4
}

print("\n")
common_key.run_sequence(tan_click_ng4)
