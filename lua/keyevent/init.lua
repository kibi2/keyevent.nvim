local config = require("keyevent.config")
local os = require("keyevent.os")
local KeyEvent = require("keyevent.keyevent")
local diagnosis = require("keyevent.diagnosis")

local M = {}

---@param opts? table
function M.setup(opts)
	config.setup(opts or {})
	os.setup()
	vim.api.nvim_create_user_command("KeyEvent", function(opts)
		if opts.args == "diagnosis" then
			diagnosis.start()
		else
			vim.notify(
				"Unknown KeyEvent command: " .. opts.args,
				vim.log.levels.ERROR
			)
		end
	end, {
		nargs = 1,
		complete = function()
			return { "diagnosis" }
		end,
	})
end

function M.on_event(callback)
	KeyEvent.on_event(callback)
end

return M
