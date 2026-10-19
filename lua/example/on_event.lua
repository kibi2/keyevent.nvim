local KeyEvent = require("keyevent.keyevent")
local seqs = {
	{ key = "k", meta = 0 },
	{ key = "j", meta = 0, type = KeyEvent.KEY_EVENT_TYPE.TAP },
}
require("keyevent").on_event(function()
	if vim.fn.mode() == "i" then
		if KeyEvent.match(seqs) then
			local keys = vim.api.nvim_replace_termcodes(
				"<BS><BS><Esc>",
				true,
				false,
				true
			)
			vim.api.nvim_feedkeys(keys, "n", false)
		end
	end
end)
