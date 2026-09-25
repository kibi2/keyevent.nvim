local Histgram = require("keyevent.histgram")
local log = require("keyevent.log")

local M = {}

local DELTA = 50

M.delay = 0
M.interval = 0

local prev_interval = { math.huge, math.huge }
local hist = Histgram.new(5, 10)
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

---@param histgram Histgram
---@param interval integer
---@param delay integer
local function hist_add(histgram, interval, delay)
	if delay < MAX_DELAY then
		Histgram.add(histgram, interval, delay)
	end
end

---@param event KeyEvent
function M.on_event(event)
	if is_repeat(event) then
		repeat_count = repeat_count + 1
		if repeat_count == 1 then
			delay = prev_interval[1]
			hist_add(hist, prev_interval[2], delay)
		end
		hist_add(hist, event.interval, delay)
	elseif repeat_count ~= 0 then
		repeat_count = 0
		local ave, delay_hist = Histgram.median_average(hist)
		M.interval = math.floor(ave)
		if delay_hist then
			M.delay = math.floor(Histgram.median_average(delay_hist))
			log.debug("\n" .. Histgram.to_string(delay_hist))
			log.debug("\n" .. Histgram.to_string(hist))
		end
		log.debug({ M.delya, M.interval })
	end
	prev_interval[1] = prev_interval[2]
	prev_interval[2] = event.interval
end

return M
