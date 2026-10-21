local KeyEvent = require("keyevent.keyevent")
local log = require("keyevent.log")

local META = KeyEvent.meta()
local repeat_timer = vim.loop.new_timer()
local scheme = nil

local buf
local win

local function show()
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local target_buf = buf
	local keys = KeyEvent.keys(10)
	local lines = {
		"===== keyevent.nvim: Sequence Demo =====",
		"",
		"HHH + H (click H, tap H, tap H, click H): Open this window",
		"Esc: Exit demo",
		"--------------------------------------------",
		"",
		"type ",
		"key  " .. keys,
		"meta ",
		"-----",
		"histogram",
	}
	vim.schedule(function()
		vim.bo[target_buf].modifiable = true
		vim.api.nvim_buf_set_lines(target_buf, 0, -1, false, lines)
		vim.bo[target_buf].modifiable = false
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
local seqs_tatatan_tan = {
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.TAP },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.TAP },
	{ key = "h", meta = META.S, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
}

local function demo_start()
	create_window()
end

local function demo_end()
	close()
end

local function on_event(event)
	if KeyEvent.match(seqs_esc) then
		demo_end()
		log.debug("demo end")
		return
	end
	if KeyEvent.match(seqs_tatatan_tan) then
		demo_start()
		log.debug("demo start")
	end
	show()
end

require("keyevent").on_event(function(event)
	on_event(event)
end)
