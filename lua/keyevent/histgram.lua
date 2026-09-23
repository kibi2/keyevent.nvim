local M = {}

---@class HistgramBin
---@field count integer
---@field total number

---@class Histgram
---@field bin integer
----@field bins table<integer, HistgramBin>
---@field bins HistgramBin[]

---@param bin integer
---@return Histgram
function M.new(bin)
	return {
		bin = bin,
		count = 0,
		bins = {},
	}
end

---@param hist Histgram
---@param value number
function M.add(hist, value)
	local index = math.floor(value / hist.bin)
	local bin = hist.bins[index]
	if not bin then
		bin = {
			count = 0,
			total = 0,
		}
		hist.bins[index] = bin
	end
	bin.count = bin.count + 1
	bin.total = bin.total + value
end

---@param hist Histgram
---@return number
function M.median_average(hist)
	if next(hist.bins) == nil then
		return math.huge
	end
	local indexes = {}
	local ntotal = 0
	for index, bin in pairs(hist.bins) do
		indexes[#indexes + 1] = index
		ntotal = ntotal + bin.count
	end
	table.sort(indexes)
	local middle = math.ceil(ntotal / 2)
	local count = 0
	for _, index in ipairs(indexes) do
		local bin = hist.bins[index]
		count = count + bin.count
		if count >= middle then
			return bin.total / bin.count
		end
	end
	return math.huge
end

return M
