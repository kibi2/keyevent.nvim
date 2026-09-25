local KeyEvent = require 'keyevent.keyevent'
vim.keymap.set('n', 'n', function()
    local event = KeyEvent.keymap_event 'n'
    if event.nr == 1 and event.nt == 2 then
        return ':history /<Enter>'
    elseif event.nr > 1 and event.nt == 2 then
        return ''
    end
    return 'n'
end, { expr = true })
