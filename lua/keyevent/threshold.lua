local config = require("keyevent.config")
local os = require("keyevent.os")
local analyzer = require("keyevent.analyzer")
local log = require("keyevent.log")

local M = {}

---@return integer
local function get_delay()
	if config.threshold.delay then
		return config.threshold.delay
	end
	if os.delay then
		return os.delay
	end
	return analyzer.delay
end

---@return integer
local function get_interval()
	if config.threshold.interval then
		return config.threshold.interval 
	end
	if os.interval then
		return os.interval
	end
	return analyzer.interval
end

---@return integer
local function get_tap()
	if config.threshold.tap then
		return config.threshold.tap
	end
	return vim.o.timeoutlen
end

local function get_delta()
	if config.threshold.delta then
		return config.threshold.delta
	end
	if vim.o.ttimeoutlen < 0 then
		return 50
	end
	return vim.o.ttimeoutlen
end

---@param interval integer
---@return boolean
function M.is_hold(interval)
	return math.abs(get_delay() - interval) <= get_delta()
end

---@param interval integer
---@return boolean
function M.is_repeat(interval)
	return math.abs(get_interval() - interval) <= get_delta()
end

---@param interval integer
---@return boolean
function M.is_tap(interval)
	return interval <= get_tap()
end

function M.get_repeat_time()
	return math.max(get_tap(), get_interval() + get_delta())
end

return M
