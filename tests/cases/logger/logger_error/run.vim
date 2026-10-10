source $KIBI2_REPO_ROOT/tests/common.vim

" ===== logger =====
new

CASE logger

lua << EOF
    local root = assert(os.getenv("KIBI2_REPO_ROOT"))
    vim.opt.rtp:prepend(root)
    vim.opt.rtp:prepend(root .. "/../logger.nvim")
    require("kibi2.logger").setup({
        level = vim.log.levels.DEBUG,
        output = "print",
    })

    package.loaded["keyevent.log"] = nil
    log = require("keyevent.log")
    log.debug("log debug %d %s %s", 1, "two", "three")
    log.info("log info %d %s %s", 1, "two", "three")
    log.warn("log warn %d %s %s", 1, "two", "three")
    log.probe("log probe %d %s %s", 1, "two", "three")
    log.watch("LOG", "watch")
    print(log.is_debug())
    log.assert(true, "OK")
    log.error("log error")
EOF

call Snapshot({ 'desc': 'logger' })
