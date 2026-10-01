local api = vim.api -- Neovim

local config = require("keyevent.config")
local os = require("keyevent.os")
local KeyEvent = require("keyevent.keyevent")
local diagnosis = require("keyevent.diagnosis")

local M = {}

local GROUP_NAME = "keyevent"

local function initialize()
	config.setup({})
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
	local augroup = api.nvim_create_augroup(GROUP_NAME, { clear = true })
	if vim.g.kibi2_test_mode == 1 then
		local ok, luacov = pcall(require, "luacov")
		if ok then
			api.nvim_create_autocmd("VimLeavePre", {
				group = augroup,
				callback = function(args)
					luacov.save_stats()
				end,
			})
		end
	end
end

---@param opts? table
function M.setup(opts)
	config.setup(opts or {})
end

function M.on_event(callback)
	KeyEvent.on_event(callback)
end

initialize()

return M
