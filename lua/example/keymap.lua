local KeyEvent = require("keyevent.keyevent")
local seqs = {
	{ key = "n", meta = 0, type = KeyEvent.KEY_EVENT_TYPE.CLICK },
	{ key = "n", meta = 0, type = KeyEvent.KEY_EVENT_TYPE.TAP },
	{ key = "n", meta = 0, type = KeyEvent.KEY_EVENT_TYPE.REPEAT },
}
vim.keymap.set("n", "n", function()
	KeyEvent.keymap_event("n")
	if KeyEvent.match(seqs) then
		return ":history /<Enter>"
	end
	return "n"
end, { expr = true })
