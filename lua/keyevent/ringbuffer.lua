local log = require("keyevent.log")

local M = {}

---@class RingBuffer<T>
---@field items T[]
---@field head integer
---@field size integer

---@generic T
---@param buffer RingBuffer<T>
---@param index integer|nil
---@return integer|nil
local function index2ibuf(buffer, index)
	index = index or 1
	if not (1 <= index and index <= buffer.size) then
		return nil
	end
	local ibuf = buffer.head - (index - 1)
	if ibuf < 1 then
		ibuf = ibuf + buffer.size
	end
	return ibuf
end

---@generic T
---@param size integer
---@return RingBuffer<T>
function M.new(size)
	assert(size >= 1 and size % 1 == 0, "size must be a positive integer")
	---@type RingBuffer
	return {
		items = {},
		head = size,
		size = size,
	}
end

---@generic T
---@param buffer RingBuffer<T>
---@return RingBuffer<T>
function M.copy(buffer)
	return vim.deepcopy(buffer)
end

---@generic T
---@param buffer RingBuffer<T>
---@param item T
function M.push(buffer, item)
	assert(item ~= nil, "item must not be nil")
	buffer.head = buffer.head % buffer.size + 1
	buffer.items[buffer.head] = item
end

---@generic T
---@param buffer RingBuffer<T>
---@param index integer
---@param item T
function M.set(buffer, index, item)
	assert(item ~= nil, "item must not be nil")
	local ibuf = index2ibuf(buffer, index)
	if not ibuf then
		return
	end
	buffer.items[ibuf] = item
end

---@generic T
---@param buffer RingBuffer<T>
---@param index integer
---@return T|nil
function M.get(buffer, index)
	local ibuf = index2ibuf(buffer, index)
	if not ibuf then
		return nil
	end
	return buffer.items[ibuf]
end

---@generic T
---@param buffer RingBuffer<T>
---@return T
function M.peek(buffer)
	local ibuf = index2ibuf(buffer, 1)
	return buffer.items[ibuf]
end

---@generic T
---@param buffer RingBuffer<T>
---@param size integer
---@return T[]
function M.get_recent(buffer, size)
	local items = {}
	for index = math.min(size, buffer.size), 1, -1 do
		items[#items + 1] = M.get(buffer, index)
	end
	return items
end

return M
