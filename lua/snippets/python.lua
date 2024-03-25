local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local sn = ls.snippet_node

return {
  -- Create list:
  s('li', {
    t '["',
    i(1),
    t '"',
    i(2),
    t ']',
  }),
}, {
  -- Add to list:
  s('i', {
    t ', "',
    i(1),
    t '"',
  }),
}
