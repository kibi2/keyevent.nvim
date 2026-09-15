local diagnosis = require("keyevent.diagnosis")
local KeyEvent = require("keyevent.keyevent")

local M = {}

---@param opts? table
function M.setup(opts)
	KeyEvent.setup(opts or {})
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

return M
