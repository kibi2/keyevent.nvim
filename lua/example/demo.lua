local KeyEvent = require("keyevent.keyevent")
local log = require("keyevent.log")

local demo_mode = false

local buf
local win

local function show()
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.bo[buf].modifiable = true
end

local function close()
	vim.schedule(function()
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		win = nil
		buf = nil
	end)
end

local function create_window()
	buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	local width = 64
	local height = 35
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

local origin_scheme
local color_scheme
local ischeme

local function demo_color_scheme_reset()
	if origin_scheme then
		vim.cmd.colorscheme(origin_scheme)
	end
	origin_scheme = nil
	color_scheme = nil
	ischeme = nil
end

local function demo_begin()
	local seq = KeyEvent.keys(3)
	if seq ~= "<S-h><S-h><S-h>" then
		return
	end
	demo_mode = true
	create_window()
end

local function demo_end()
	local events = KeyEvent.get_events(1)
	if events[1].key ~= "<Esc>" then
		return
	end
	demo_mode = false
	demo_color_scheme_reset()
	close()
end

local function demo_color_scheme()
	local seq = KeyEvent.keys(1)
	if seq ~= "<S-m>" then
		return
	end

	if not color_scheme then
		origin_scheme = vim.g.colors_name or "default"
		color_scheme = vim.fn.getcompletion("", "color")
		ischeme = 0
	end

	ischeme = ischeme % #color_scheme + 1
	vim.cmd.colorscheme(color_scheme[ischeme])
	print(color_scheme[ischeme])
end

local function on_event()
	demo_begin()
	demo_end()
	if not demo_mode then
		return
	end
	demo_color_scheme()
end

require("keyevent").on_event(function()
	if vim.fn.mode() == "n" then
		on_event()
	end
end)
