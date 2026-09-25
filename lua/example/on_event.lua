local KeyEvent = require 'keyevent.keyevent'
require('keyevent').on_event(function()
  if vim.fn.mode() == 'i' then
    local seq = KeyEvent.keys(2)
    if seq == 'kj' then
      local keys = vim.api.nvim_replace_termcodes('<BS><BS><Esc>', true, false, true)
      vim.api.nvim_feedkeys(keys, 'n', false)
    end
  end
end)