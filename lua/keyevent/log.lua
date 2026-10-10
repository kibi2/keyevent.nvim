local ok, logger = pcall(require, "kibi2.logger.logger")

if not ok then
	logger = {
		debug = function() end,
		info = function() end,
		warn = function() end,
		error = function(...)
			local message = table.concat(vim.tbl_map(tostring, { ... }), " ")
			vim.schedule(function()
				vim.notify(message, vim.log.levels.ERROR)
			end)
		end,
		probe = function() end,
		watch = function() end,
		is_debug = function()
			return false
		end,
		assert = function(condition, message, ...)
			if not condition then
				error(string.format(message, ...), 2)
			end
			return condition
		end,
	}
end

-- =============================================================================

local M = {}

-- =============================================================================
-- Public API

---@param ... unknown
function M.debug(...)
	logger.debug(...)
end

---@param ... unknown
function M.info(...)
	logger.info(...)
end

---@param ... unknown
function M.warn(...)
	logger.warn(...)
end

---@param ... unknown
function M.error(...)
	logger.error(...)
end

---@param ... unknown
function M.probe(...)
	logger.probe(...)
end

---@param category string
---@param ... unknown
function M.watch(category, ...)
	logger.watch(category, ...)
end

---@return boolean
function M.is_debug()
	return logger.is_debug()
end

---@param condition any
---@param message string
---@param ... unknown
function M.assert(condition, message, ...)
	logger.assert(condition, message, ...)
end

return M
