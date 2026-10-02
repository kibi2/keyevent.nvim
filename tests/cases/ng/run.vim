source $KIBI2_REPO_ROOT/tests/common.vim

" ===== NG case =====
new

CASE : tan click NG
lua require "run_click"

CASE : tan hold NG
lua require "run_hold"

CASE : tan repeat NG
lua require "run_repeat"

CASE : tan tap NG
lua require "run_tap"

call Snapshot({ 'desc': 'NG case' })
