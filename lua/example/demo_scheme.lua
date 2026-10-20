local KeyEvent = require("keyevent.keyevent")
local log = require("keyevent.log")
---@enum DemoScheme
local STATE = {
	NORMAL = "NORMAL",
	DEMO = "DEMO",
	HOLD = "HOLD",
	HOLD_R = "HOLD_R",
	SLIDE = "SLIDE",
}

---@type DemoScheme
local state = STATE.NORMAL
local META = KeyEvent.meta()
local repeat_timer = vim.loop.new_timer()
local scheme = nil

local buf
local win

local function color_name()
	if not scheme then
		return vim.g.colors_name or "default"
	end
	return scheme.colors[scheme.index]
end

local function show(interval)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local lines = {
		"===== keyevent.nvim: Color Scheme Demo =====",
		"",
		"HH + HH (click H, tap H, click H, tap H): Open this window",
		"Click H: Change color scheme",
		"Click h: Change color scheme in reverse order",
		"Hold H: Start slideshow on release",
		"          Hold duration determines slideshow interval",
		"Tap H + hold H: Start slideshow in reverse order",
		"Any key: Stop slideshow",
		"Esc: Exit demo",
		"--------------------------------------------",
		"",
		"Color name: " .. color_name(),
		"Slideshow interval: " .. (interval and (interval .. " ms") or "N/A"),
	}
	vim.schedule(function()
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false
	end)
end

local function create_window()
	if win and vim.api.nvim_win_is_valid(win) then
		return
	end
	buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	local width = 64
	local height = 15
	local ui = vim.api.nvim_list_uis()[1] or { width = 80, height = 24 }
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

local function close()
	local closing_win = win
	win = nil
	buf = nil
	vim.schedule(function()
		if closing_win and vim.api.nvim_win_is_valid(closing_win) then
			vim.api.nvim_win_close(closing_win, true)
		end
	end)
end

local seqs_esc = {
	{ key = "<Esc>" },
}
local seqs_tatan_tatan = {
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.TAP },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.TAP },
}
local seqs_tan = {
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
}
local seqs_tan_h = {
	{ key = "h", meta = 0, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
}
local seqs_taan = {
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.REPEAT },
}
local seqs_tataan = {
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.TAP },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.REPEAT },
}

local function demo_color_scheme_set()
	local origin = vim.g.colors_name or "default"
	local colors = vim.fn.getcompletion("", "color")
	local index = vim.fn.index(colors, origin)
	scheme = {
		origin = origin,
		colors = colors,
		index = index >= 0 and index + 1 or 1,
	}
end

local function demo_color_scheme_reset()
	if scheme then
		vim.cmd.colorscheme(scheme.origin)
	end
	scheme = nil
end

---@param index integer
---@param max integer
---@param reverse boolean
---@return integer
local function next_index(index, max, reverse)
	local step = reverse and -1 or 1
	index = index + step
	index = index % max
	if index == 0 then
		index = max
	end
	return index
end

---@param reverse boolean
---@param interval integer|nil
local function demo_color_scheme(reverse, interval)
	if not scheme then
		return
	end
	scheme.index = next_index(scheme.index, #scheme.colors, reverse)
	local name = scheme.colors[scheme.index]
	vim.cmd.colorscheme(name)
	log.debug(name)
	show(interval)
end

local function stop_repeat_timer()
	repeat_timer:stop()
end

local function close_repeat_timer()
	if not repeat_timer:is_closing() then
		repeat_timer:stop()
		repeat_timer:close()
	end
end

---@param interval integer
---@param reverse boolean
local function start_repeat_timer(interval, reverse)
	log.debug(interval, reverse)
	repeat_timer:start(
		0,
		interval,
		vim.schedule_wrap(function()
			demo_color_scheme(reverse, interval)
		end)
	)
end

local function demo_start()
	demo_color_scheme_set()
	create_window()
end

local function demo_end()
	demo_color_scheme_reset()
	close()
end

local function normal()
	if not KeyEvent.match(seqs_tatan_tatan) then
		return
	end
	demo_start()
	state = STATE.DEMO
	log.debug("demo start")
end

local function demo()
	if KeyEvent.match(seqs_esc) then
		demo_end()
		state = STATE.NORMAL
		log.debug("demo end")
		return
	end
	if KeyEvent.match(seqs_tan) then
		demo_color_scheme(false)
	elseif KeyEvent.match(seqs_tan_h) then
		demo_color_scheme(true)
	end
	if KeyEvent.match(seqs_tataan) then
		state = STATE.HOLD_R
	elseif KeyEvent.match(seqs_taan) then
		state = STATE.HOLD
	end
end

---@param event KeyEvent
---@param reverse boolean
local function hold(event, reverse)
	local interval = KeyEvent.hold_time(event)
	if event.type == KeyEvent.KEY_EVENT_TYPE.REPEAT_END then
		start_repeat_timer(interval, reverse)
		state = STATE.SLIDE
		log.debug(string.format("slide start : %d %s ", interval, reverse))
	elseif event.type == KeyEvent.KEY_EVENT_TYPE.REPEAT then
		show(interval)
	else
		state = STATE.DEMO
		show(0)
		log.debug("hold end")
	end
end

local function slide()
	stop_repeat_timer()
	if KeyEvent.match(seqs_esc) then
		demo_end()
		state = STATE.NORMAL
		log.debug("demo end")
	else
		state = STATE.DEMO
		log.debug("slide end")
	end
end

local function on_event(event)
	if state == STATE.NORMAL then
		normal()
	elseif state == STATE.DEMO then
		demo()
	elseif state == STATE.HOLD then
		hold(event, false)
	elseif state == STATE.HOLD_R then
		hold(event, true)
	elseif state == STATE.SLIDE then
		slide()
	else
		assert(false, state)
	end
end

require("keyevent").on_event(function(event)
	if vim.fn.mode() == "n" then
		on_event(event)
	end
end)

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = close_repeat_timer,
})
