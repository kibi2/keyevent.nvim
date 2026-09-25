local M = {}

local default_config = {
	threshold = {
		delta = 20,
		tap = 500,
	},
	log = {
		level = vim.log.levels.ERROR,
		output = "file", -- "buffer", "file", "print", "notify"
		buffer_name = "keyevent://log",
		file_name = "/tmp/keyevent.log",
		use_timestamp = false,
		single_line = true,
		probe = true,
		monitor = false,
	},
}

function M.setup(opts)
	local config =
		vim.tbl_deep_extend("force", vim.deepcopy(default_config), opts or {})
	for key, value in pairs(config) do
		M[key] = value
	end
end

return M
