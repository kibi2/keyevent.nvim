source $KIBI2_REPO_ROOT/tests/common.vim

" ===== BASIC =====
new

lua require("run")
CASE OS prefs
lua print(Os.delay, Os.interval)

call Snapshot({ 'desc': 'basic' })
