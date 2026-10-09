local logger = require("kibi2.logger.logger")

-- =============================================================================

local M = {}

--#endregion
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
