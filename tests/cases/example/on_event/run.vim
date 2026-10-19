source $KIBI2_REPO_ROOT/tests/common.vim

" ===== BASIC =====
new

CASE : example demo
lua require "run"

call Snapshot({ 'desc': 'example demo' })
