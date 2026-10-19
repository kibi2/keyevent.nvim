local common_key = require("common_key")
local root = assert(os.getenv("KIBI2_REPO_ROOT"))
vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(root .. "/../logger.nvim")
package.loaded["keyevent.log"] = nil
local log = require("keyevent.log")
require("example.demo_scheme")
log.setup({
	level = vim.log.levels.DEBUG,
	output = "print",
})
log.debug("hoge")

---@type KeyInfo[]
local demo = {
	{ key = "H", interval = CLICK },
	{ key = "H", interval = TAP },
	{ key = "H", interval = CLICK },
	{ key = "H", interval = TAP },
	{ key = "H", interval = CLICK }, -- next
	{ key = "H", interval = CLICK }, -- slide
	{ key = "H", interval = REPEAT },
	{ key = "L", interval = CLICK }, -- end
	{ key = "H", interval = CLICK }, -- slide reverse
	{ key = "H", interval = TAP },
	{ key = "H", interval = REPEAT },
	{ key = "L", interval = CLICK }, -- end
	{ key = "<Esc>", interval = TAP },
}

common_key.run_sequence(demo)
