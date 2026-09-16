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

---@param interval integer
---@return boolean
function M.is_delay(interval)
    log.probe(get_delay())
    log.probe(interval)
    log.probe(config.threshold.delta)
    return math.abs(get_delay() - interval) <= config.threshold.delta
end

---@param interval integer
---@return boolean
function M.is_interval(interval)
    return math.abs(get_interval() - interval) <= config.threshold.delta
end

---@param interval integer
---@return boolean
function M.is_tap(interval)
    return interval <= config.threshold.tap
end

return M
