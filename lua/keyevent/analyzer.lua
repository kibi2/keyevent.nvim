local KeyEvent = require("keyevent.keyevent")
local Histgram = require("keyevent.histgram")
local log = require("keyevent.log")

local M = {}

local DELTA = 50

M.prefs = {
	delay = 0,
	interval = 0,
}

local prev_interval = { math.huge, math.huge }
local hist_repeat = Histgram.new(5)
local hist_leader = Histgram.new(10, true)
local repeat_count = 0
local MAX_DELAY = 1050
local delay = MAX_DELAY

local function neary_equal(val1, val2)
	return math.abs(val1 - val2) <= DELTA
end

---@param event KeyEvent
local function is_repeat(event)
	if event.key ~= event.prev_key then
		return false
	end
	if prev_interval[2] >= MAX_DELAY then
		return false
	end
	if prev_interval[1] >= MAX_DELAY then
		return false
	end
	return neary_equal(event.interval, prev_interval[2])
end

local function hist_add(histgram, interval)
	if delay < MAX_DELAY then
		Histgram.add(histgram, interval)
	end
end

---@param event KeyEvent
local function on_event(event)
	if is_repeat(event) then
		repeat_count = repeat_count + 1
		if repeat_count == 1 then
			delay = prev_interval[1]
			hist_add(hist_leader, delay)
			hist_add(hist_repeat, prev_interval[2])
		end
		hist_add(hist_repeat, event.interval)
	elseif repeat_count ~= 0 then
		repeat_count = 0
		M.prefs.interval = math.floor(Histgram.median_average(hist_repeat))
		if Histgram.mode_ratio(hist_leader) > 0.5 then
			M.prefs.delay = math.floor(Histgram.mode_ave(hist_leader))
		else
			M.prefs.delay = M.prefs.interval
		end
		log.probe("\n" .. Histgram.to_string(hist_leader))
		log.probe("\n" .. Histgram.to_string(hist_repeat))
		log.probe(M.prefs)
	end
	prev_interval[1] = prev_interval[2]
	prev_interval[2] = event.interval
end

function M.setup()
	KeyEvent.on_event(on_event)
end

return M
