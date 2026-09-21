local config = require("keyevent.config")
local os = require("keyevent.os")
local log = require("keyevent.log")

local M = {}

---@return integer
local function get_delay()
	return os.delay or config.threshold.delay
end

---@return integer
local function get_interval()
	return os.interval or config.threshold.interval
end

---@return integer
local function get_tap()
	return config.threshold.tap or vim.o.timeoutlen
end

---@param interval integer
---@return boolean
function M.is_hold(interval)
	return math.abs(get_delay() - interval) <= config.threshold.delta
end

---@param interval integer
---@return boolean
function M.is_repeat(interval)
	return math.abs(get_interval() - interval) <= config.threshold.delta
end

---@param interval integer
---@return boolean
function M.is_tap(interval)
	return interval <= get_tap()
end

function M.get_repeat_time()
	return math.max(get_tap(), get_interval() + config.threshold.delta)
end

return M
