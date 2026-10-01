local bit = require("bit")

local M = {}

---@param ... integer
---@return integer
function M.new(...)
	return bit.bor(...)
end

---@param value integer
---@param ... integer
---@return integer
function M.set_on(value, ...)
	return bit.bor(value, ...)
end

---@param value integer
---@param ... integer
---@return integer
function M.set_off(value, ...)
	return bit.band(value, bit.bnot(bit.bor(...)))
end

---@param value integer
---@param ... integer
---@return boolean
function M.is_on(value, ...)
	local mask = bit.bor(...)
	return bit.band(value, mask) == mask
end

---@param value integer
---@param ... integer
---@return boolean
function M.is_off(value, ...)
	return bit.band(value, bit.bor(...)) == 0
end

---@param value integer
---@param mask_on integer
---@param mask_off integer
---@return boolean
function M.is_on_off(value, mask_on, mask_off)
	return M.is_on(value, mask_on) and M.is_off(value, mask_off)
end

return M
