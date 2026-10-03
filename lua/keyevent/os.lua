local log = require("keyevent.log")

local M = {}

local function get_prefs2(path)
	if not path then
		return
	end
	local ok, result = pcall(function()
		return vim.system({ path }):wait()
	end)
	if not ok or result.code ~= 0 then
		return
	end
	local ok, data = pcall(vim.json.decode, result.stdout)
	if ok and type(data) == "table" then
		return data
	end
end

local function get_prefs(path)
	vim.notify("get_prefs" .. path .. " found")
	if not path then
		return
	end

	vim.notify("OS" .. "run " .. path)

	local ok, result = pcall(function()
		return vim.system({ path }):wait()
	end)

	vim.notify("OS" .. "system ok = " .. tostring(ok))

	if not ok then
		vim.notify("OS" .. "system error = " .. vim.inspect(result))
		return
	end

	vim.notify("OS" .. "exit code = " .. tostring(result.code))
	vim.notify("OS" .. "stdout = " .. vim.inspect(result.stdout))
	vim.notify("OS" .. "stderr = " .. vim.inspect(result.stderr))

	if result.code ~= 0 then
		return
	end

	local ok, data = pcall(vim.json.decode, result.stdout)

	vim.notify("OS" .. "json ok = " .. tostring(ok))
	vim.notify("OS" .. "data = " .. vim.inspect(data))

	if ok and type(data) == "table" then
		return data
	end
end

local function find_tool(name)
	for _, root in ipairs(vim.api.nvim_list_runtime_paths()) do
		local path = root .. "/tools/" .. name
		vim.notify(
			"OS"
				.. "check "
				.. path
				.. " => "
				.. tostring(vim.uv.fs_stat(path) ~= nil)
		)
		if vim.uv.fs_stat(path) then
			vim.notify("find_tool" .. path .. " found")
			return path
		end
	end
end

local function get_system_prefs()
	local tools = {
		"macos/keyevent-macos",
		"windows/keyevent-win.exe",
		"X11/keyevent-x11",
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
	vim.notify("OS" .. "delay = " .. (M.delay or "nil"))
	vim.notify("OS" .. "interval = " .. (M.interval or "nil"))
end

return M
