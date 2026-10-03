source $KIBI2_REPO_ROOT/tests/common.vim

" ===== diagnosis =====
new

CASE diagnosis
execute "KeyEvent diagnosis"

lua<<EOF
local common_key = require("common_key")

---@type KeyInfo[]
local tan_tan = {
	{ key = "j", interval = CLICK }, -- tan
	{ key = "j", interval = HOLD }, -- repeat 1
	{ key = "j", interval = REPEAT }, -- repeat 2
	{ key = "j", interval = REPEAT }, -- repeat 3
	{ key = "h", interval = CLICK }, -- tan
	{ key = "h", interval = HOLD }, -- repeat 1
	{ key = "h", interval = REPEAT }, -- repeat 2
	{ key = "k", interval = TAP }, -- tan
	{ key = "k", interval = HOLD }, -- repeat 1
	{ key = "k", interval = REPEAT }, -- repeat 2
	{ key = "k", interval = REPEAT }, -- repeat 3
	{ key = "<Esc>", interval = REPEAT }, -- repeat 3
}

	for _, keyinfo in ipairs(tan_tan) do
		common_key.advance(keyinfo.interval)
        local keys = vim.api.nvim_replace_termcodes(keyinfo.key, true, false, true)
        vim.api.nvim_feedkeys(keys, "xt", false)
		--KeyEvent.on_key_test(keyinfo.key)
	end
	local analyzer = require("keyevent.analyzer")
    print(analyzer.delay, analyzer.interval)
EOF

CASE NG command
execute "KeyEvent diagnosisX"

call Snapshot({ 'desc': 'diagnosis' })
