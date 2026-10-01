source $KIBI2_REPO_ROOT/tests/common.vim

" ===== BASIC =====
new

lua << EOF
local run = require("run")
print(Os.delay, Os.interval)
EOF

call Snapshot({ 'desc': 'basic' })
