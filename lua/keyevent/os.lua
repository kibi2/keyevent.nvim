local log = require("keyevent.log")

local M = {}
local function get_prefs(path)
	if not path then
		return
	end
	local result = vim.system({ path }):wait()
	if result.code ~= 0 then
		return
	end
	local ok, data = pcall(vim.json.decode, result.stdout)
	if ok and type(data) == "table" then
		return data
	end
end

local function find_tool(name)
	for _, root in ipairs(vim.api.nvim_list_runtime_paths()) do
		local path = root .. "/tools/" .. name
		if vim.uv.fs_stat(path) then
			return path
		end
	end
end

local function get_system_prefs()
	local tools = {
		"macos/keyevent-macos",
		"windows/keyevent-win.exe",
		"linux/keyevent-x11",
	}
	for _, name in ipairs(tools) do
		local prefs = get_prefs(find_tool(name))
		if prefs then
			return prefs
		end
	end
end

function M.setup()
	local prefs = get_system_prefs()
	if prefs then
		M.delay = prefs.delay
		M.interval = prefs.interval
	end
	log.probe("delay = " .. (M.delay or "nil"))
	log.probe("interval = " .. (M.interval or "nil"))
end

return M
