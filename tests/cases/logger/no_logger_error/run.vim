source $KIBI2_REPO_ROOT/tests/common.vim

" ===== logger =====
new

CASE logger

lua << EOF
    package.loaded["keyevent.log"] = nil
    log = require("keyevent.log")
    log.debug("log debug %d %s %s", 1, "two", "three")
    log.info("log info %d %s %s", 1, "two", "three")
    log.warn("log warn %d %s %s", 1, "two", "three")
    log.probe("log probe %d %s %s", 1, "two", "three")
    log.watch("LOG", "watch")
    print(log.is_debug())
    log.assert(true, "OK")
    log.error("log error %d %d %s", 1, 2, "three")
    log.error(1, 2, "three")
EOF

call Snapshot({ 'desc': 'logger' })
