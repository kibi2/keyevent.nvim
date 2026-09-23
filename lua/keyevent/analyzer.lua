local KeyEvent = require("keyevent.keyevent")
local log = require("keyevent.log")

local M = {}

---@class Sample
---@field leader KeyEvent
---@field count integer
---@field total integer
---@field events KeyEvent[]

local DELTA = 50
local MIN_COUNT = 3
local MAX_SAMPLE = 3
local nsample = MAX_SAMPLE

M.prefs = {
	delay = 0,
	interval = 0,
}

---@type Sample
local sample = {
	leader = KeyEvent.START_EVENT,
	count = 0,
	total = 0,
	events = {},
}

local master = vim.deepcopy(sample)

local function neary_equal(val1, val2)
	return math.abs(val1 - val2) <= DELTA
end

local function get_ave()
	if sample.count == 0 then
		return math.huge / 2
	end
	return math.floor(sample.total / sample.count)
end

---@param event KeyEvent
local function on_event(event)
	if neary_equal(event.interval, get_ave()) then
		sample.count = sample.count + 1
		sample.total = sample.total + event.interval
		sample.events[sample.count] = event
	else
		if sample.count == 1 then
			sample.leader = sample.events[sample.count]
		else
			sample.leader = event
			if sample.count >= master.count then
				master = vim.deepcopy(sample)
				log.probe(
					"master %d %d %d",
					master.count,
					master.leader.interval,
					M.prefs.interval
				)
			end
		end
		sample.count = 1
		sample.total = event.interval
		sample.events[sample.count] = event
	end
	if sample.count > math.max(master.count, 2) then
		M.prefs.interval = get_ave()
		M.prefs.delay = M.prefs.interval
		if neary_equal(sample.leader.interval, master.leader.interval) then
			M.prefs.delay = sample.leader.interval
		end
		log.probe(M.prefs)
	end
end

function M.setup()
	KeyEvent.on_event(on_event)
end

return M
