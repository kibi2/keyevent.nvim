local config = require("keyevent.config")
local os = require("keyevent.os")
local analyzer = require("keyevent.analyzer")

local M = {}

--------------------------------------------------
-- config
--------------------------------------------------

local key_set = { "h", "j", "k", "l" }

--------------------------------------------------
-- state
--------------------------------------------------

local buf
local win

local origin_buf

local prev_key = ""
local prev_time = 0
local first_repeat = true

local hold_intervals = {}
local repeat_intervals = {}

local display_pending = false

local saved_keymaps = {}

--------------------------------------------------
-- utility
--------------------------------------------------

---@param values integer[]
---@return integer|nil
local function min_value(values)
	if #values == 0 then
		return nil
	end
	local result = values[1]
	for index = 2, #values do
		result = math.min(result, values[index])
	end
	return result
end

---@param values integer[]
---@return integer|nil
local function max_value(values)
	if #values == 0 then
		return nil
	end
	local result = values[1]
	for index = 2, #values do
		result = math.max(result, values[index])
	end
	return result
end

---@param value integer|nil
---@return string
local function format_value(value)
	if value == nil then
		return "-"
	end
	return tostring(value)
end

--------------------------------------------------
-- measurement
--------------------------------------------------

---@param key string
local function measure_key(key)
	local now = vim.loop.hrtime()
	if prev_key ~= key then
		prev_key = key
		prev_time = now
		first_repeat = true
		return
	end
	local delta_t = math.floor((now - prev_time) / 1e6 + 0.5)
	if first_repeat then
		table.insert(hold_intervals, delta_t)
		first_repeat = false
	else
		-- local hold_max = max_value(hold_intervals)
		-- if delta_t <= hold_max then
		table.insert(repeat_intervals, delta_t)
		-- else
		-- first_repeat = true
		-- end
	end
	prev_time = now
end

--------------------------------------------------
-- suggested configuration
--------------------------------------------------

---@return string[]
local function suggested_config()
	local hold_min = min_value(hold_intervals)
	local hold_max = max_value(hold_intervals)
	local repeat_min = min_value(repeat_intervals)
	local repeat_max = max_value(repeat_intervals)
	local interval
	if repeat_max and repeat_min then
		interval = math.ceil((repeat_max + repeat_min) / 2)
	end
	local delay
	if hold_max and hold_min then
		delay = math.ceil((hold_max + hold_min) / 2)
	end
	return {
		"  delay    = " .. format_value(delay) .. ",",
		"  interval = " .. format_value(interval) .. ",",
	}
end

--------------------------------------------------
-- display
--------------------------------------------------

---@return string[]
local function make_lines()
	local hold_min = min_value(hold_intervals)
	local hold_max = max_value(hold_intervals)
	local repeat_min = min_value(repeat_intervals)
	local repeat_max = max_value(repeat_intervals)
	local lines = {
		"===== Key event diagnosis =====",
		"",
		"Press and hold one of these keys:",
		"  'h', 'j', 'k', or 'l'",
		"Repeat the measurement several times.",
		"",
		"Use a different key for each measurement.",
		"For example:",
		"",
		"  hold j",
		"  hold k",
		"  hold j",
		"  hold k",
		"",
		"----------------------------------------",
		"Detected intervals:",
		"",
		"        count   min(ms)   max(ms)",
		string.format(
			"delay    %5d   %7s   %7s",
			#hold_intervals,
			format_value(hold_min),
			format_value(hold_max)
		),
		string.format(
			"interval %5d   %7s   %7s",
			#repeat_intervals,
			format_value(repeat_min),
			format_value(repeat_max)
		),
		"",
		"Suggested configuration:",
		"",
	}
	vim.list_extend(lines, suggested_config())
	vim.list_extend(lines, {
		"",
		"----------------------------------------",
		"",
		"            delay  interval       tap     delta",
		string.format(
			"  config%9s %9s %9s %9s",
			format_value(config.threshold.delay),
			format_value(config.threshold.interval),
			format_value(config.threshold.tap),
			format_value(config.threshold.delta)
		),
		string.format(
			"  os    %9s %9s",
			format_value(os.delay),
			format_value(os.interval)
		),
		string.format(
			"  analyzer  %5s %9s",
			format_value(analyzer.delay),
			format_value(analyzer.interval)
		),
		"",
		"Press <Esc> to close.",
	})
	return lines
end

local function show()
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, make_lines())
end

local function schedule_show()
	if display_pending then
		return
	end
	display_pending = true
	vim.schedule(function()
		display_pending = false
		show()
	end)
end

--------------------------------------------------
-- temporary keymaps
--------------------------------------------------

---@param key string
local function save_keymap(key)
	local maps = vim.api.nvim_buf_get_keymap(origin_buf, "n")
	for _, map in ipairs(maps) do
		if map.lhs == key then
			saved_keymaps[key] = map
			return
		end
	end
	saved_keymaps[key] = nil
end

local function restore_keymaps()
	for _, key in ipairs(key_set) do
		local map = saved_keymaps[key]
		-- Remove the temporary diagnosis mapping.
		pcall(vim.keymap.del, "n", key, {
			buffer = origin_buf,
		})
		-- Restore the original mapping, if there was one.
		if map then
			vim.keymap.set("n", key, map.rhs, {
				buffer = origin_buf,
				expr = map.expr == 1,
				silent = map.silent == 1,
				noremap = map.noremap == 1,
			})
		end
	end
	saved_keymaps = {}
end

local function close()
	vim.schedule(function()
		restore_keymaps()
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		win = nil
		buf = nil
	end)
end

---@return string
local function on_escape()
	close()
	return ""
end

local function setup_keymaps()
	for _, key in ipairs(key_set) do
		save_keymap(key)
		vim.keymap.set("n", key, function()
			measure_key(key)
			schedule_show()
			return key
		end, {
			buffer = origin_buf,
			expr = true,
			silent = true,
		})
	end
	vim.keymap.set("n", "<Esc>", on_escape, {
		buffer = origin_buf,
		expr = true,
		silent = true,
	})
	vim.keymap.set("n", "<Esc>", on_escape, {
		buffer = buf,
		expr = true,
		silent = true,
	})
end

--------------------------------------------------
-- float
--------------------------------------------------

local function create_window()
	buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	local width = 64
	local height = 35
	local ui = vim.api.nvim_list_uis()[1]
	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)
	win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})
	vim.wo[win].wrap = false
	vim.wo[win].cursorline = false
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	show()
end

--------------------------------------------------
-- public
--------------------------------------------------

function M.start()
	if win and vim.api.nvim_win_is_valid(win) then
		return
	end
	prev_key = ""
	prev_time = 0
	first_repeat = true
	hold_intervals = {}
	repeat_intervals = {}
	display_pending = false
	saved_keymaps = {}
	origin_buf = vim.api.nvim_get_current_buf()
	create_window()
	setup_keymaps()
end

return M