source $KIBI2_REPO_ROOT/tests/common.vim

" ===== BASIC =====
new

CASE : tan tan ta ta tan
lua require "run1"

CASE : tan tan ta ta tan (meta)
lua require "run2"

CASE : tan tan ta ta tan (diff key)
lua require "run3"

CASE : tan tan ta ta tan (interval)
lua require "run4"

call Snapshot({ 'desc': 'basic' })
