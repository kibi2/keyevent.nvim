source $KIBI2_REPO_ROOT/tests/common.vim

" ===== OS prefs =====
new

CASE OS prefs
lua Os = require("keyevent.os")
lua print(Os.delay, Os.interval)

call Snapshot({ 'desc': 'os prefs' })
