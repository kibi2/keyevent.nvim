local log = require("keyevent.log")

local M = {}

---@class HistogramBin
---@field count integer
---@field total number
---@field hist Histogram|nil

---@class Histogram
---@field bin1 integer
---@field bin2 integer|nil
---@field count integer
---@field bins HistogramBin[]

---@param hist Histogram
---@return integer[]
local function get_indexes(hist)
	local indexes = {}
	for index in pairs(hist.bins) do
		indexes[#indexes + 1] = index
	end
	table.sort(indexes)
	return indexes
end

---@param bin1 integer
---@param bin2 integer|nil
---@return Histogram
function M.new(bin1, bin2)
	---@type Histogram
	return {
		bin1 = bin1,
		bin2 = bin2,
		count = 0,
		bins = {},
	}
end

---@param hist Histogram
---@param index integer
---@param value integer
---@return HistogramBin
local function add_bin(hist, index, value)
	local bin = hist.bins[index]
	if not bin then
		bin = {
			count = 0,
			total = 0,
			hist = hist.bin2 and M.new(hist.bin2) or nil,
		}
		hist.bins[index] = bin
	end
	bin.count = bin.count + 1
	bin.total = bin.total + value
	return bin
end

---@param hist Histogram|nil
---@param value1 integer|nil
---@param value2 integer|nil
function M.add(hist, value1, value2)
	if not hist then
		return
	end
	hist.count = hist.count + 1
	local index = math.floor(value1 / hist.bin1)
	assert(value1)
	local bin = add_bin(hist, index, value1)
	M.add(bin.hist, value2)
end

---@param hist Histogram
---@return number
---@return Histogram|nil
function M.median_average(hist)
	if hist.count == 0 then
		return math.huge
	end
	local middle = math.ceil(hist.count / 2)
	local count = 0
	for _, index in ipairs(get_indexes(hist)) do
		local bin = hist.bins[index]
		count = count + bin.count
		if count >= middle then
			return bin.total / bin.count, bin.hist
		end
	end
	return math.huge
end

---@param hist Histogram
---@return number
function M.mode_ratio(hist)
	if hist.count == 0 then
		return 0
	end

	local max_count = 0
	for _, bin in pairs(hist.bins) do
		max_count = math.max(max_count, bin.count)
	end
	return max_count / hist.count
end

---@param hist Histogram
---@return number
---@return Histogram|nil
function M.mode_ave(hist)
	if hist.count == 0 then
		return math.huge
	end
	local mode
	for _, bin in pairs(hist.bins) do
		if not mode or bin.count > mode.count then
			mode = bin
		end
	end
	if not mode then
		return math.huge, mode.hist
	end
	return mode.total / mode.count
end

---@param hist Histogram
---@return string
function M.to_string(hist)
	local ave = {}
	local count = {}
	for _, index in ipairs(get_indexes(hist)) do
		local bin = hist.bins[index]
		ave[#ave + 1] = string.format("%4d", math.floor(bin.total / bin.count))
		count[#count + 1] = string.format("%4d", bin.count)
	end

	return table.concat(ave) .. "\n" .. table.concat(count)
end

return M
