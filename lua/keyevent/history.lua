local log = require("keyevent.log")

local M = {}

local history = {
	events = {},
	head = 20,
	size = 20,
}

---@param ihistory integer
---@return  KeyEvent
local function get(ihistory)
	if ihistory < 1 or ihistory > history.size then
		return {}
	end
	ihistory = ((ihistory - 1) % history.size) + 1
	return history.events[ihistory] or {}
end

---@param event  KeyEvent
function M.push(event)
	history.head = history.head % history.size + 1
	history.events[history.head] = event
end

---@param event  KeyEvent
function M.reset(event)
	history.events[history.head] = event
end

---@param index integer|nil
---@return  KeyEvent
function M.peek(index)
	index = index or 1
	local ihistory = history.head - (index - 1)
	return get(ihistory)
end

return M
