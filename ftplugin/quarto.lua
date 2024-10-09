local api = vim.api
local ts = vim.treesitter

vim.b.slime_cell_delimiter = '```'
vim.b['quarto_is_r_mode'] = nil
vim.b['reticulate_running'] = false

-- wrap text, but by word no character
-- indent the wrappped line
vim.wo.wrap = true
vim.wo.linebreak = true
vim.wo.breakindent = true
vim.wo.showbreak = '|'

-- don't run vim ftplugin on top
vim.api.nvim_buf_set_var(0, 'did_ftplugin', true)

-- markdown vs. quarto hacks
local ns = vim.api.nvim_create_namespace 'QuartoHighlight'
vim.api.nvim_set_hl(ns, '@markup.strikethrough', { strikethrough = false })
vim.api.nvim_set_hl(ns, '@markup.doublestrikethrough', { strikethrough = true })
vim.api.nvim_win_set_hl_ns(0, ns)

-- ts based code chunk highlighting uses a change
-- only availabl in nvim >= 0.10
if vim.fn.has 'nvim-0.10.0' == 0 then
  return
end

-- highlight code cells similar to
-- 'lukas-reineke/headlines.nvim'
-- (disabled in lua/plugins/ui.lua)
local buf = api.nvim_get_current_buf()

local parsername = 'markdown'
local parser = ts.get_parser(buf, parsername)
local tsquery = '(fenced_code_block)@codecell'

-- vim.api.nvim_set_hl(0, '@markup.codecell', { bg = '#000055' })
vim.api.nvim_set_hl(0, '@markup.codecell', {
  link = 'CursorLine',
})

local function clear_all()
  local all = api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
  for _, mark in ipairs(all) do
    vim.api.nvim_buf_del_extmark(buf, ns, mark[1])
  end
end

local function highlight_range(from, to)
  for i = from, to do
    vim.api.nvim_buf_set_extmark(buf, ns, i, 0, {
      hl_eol = true,
      line_hl_group = '@markup.codecell',
    })
  end
end

local function highlight_cells()
  clear_all()

  local query = ts.query.parse(parsername, tsquery)
  local tree = parser:parse()
  local root = tree[1]:root()
  for _, match, _ in query:iter_matches(root, buf, 0, -1, { all = true }) do
    for _, nodes in pairs(match) do
      for _, node in ipairs(nodes) do
        local start_line, _, end_line, _ = node:range()
        pcall(highlight_range, start_line, end_line - 1)
      end
    end
  end
end

highlight_cells()

vim.api.nvim_create_autocmd({ 'ModeChanged', 'BufWrite' }, {
  group = vim.api.nvim_create_augroup('QuartoCellHighlight', { clear = true }),
  buffer = buf,
  callback = highlight_cells,
})

require('render-markdown').enable()

local ts_utils = require 'nvim-treesitter.ts_utils'
local M = {
  -- define the query
  query = vim.treesitter.query.parse('markdown', '((atx_heading) @header)'),
}
M.init = function()
  -- search the current buffer
  M.buffer = 0
  -- references to lines within the buffer
  M.first_line = 0
  M.current_line = vim.fn.line '.'
  M.previous_line = M.current_line - 1
  M.next_line = M.current_line + 1
  M.last_line = -1
  -- default count
  M.count = 1
  if vim.v.count > 1 then
    M.count = vim.v.count
  end
  -- list of captures
  M.captures = {}
  -- get the parser
  M.parser = vim.treesitter.get_parser()
  -- parse the tree
  M.tree = M.parser:parse()[1]
  -- get the root of the resulting tree
  M.root = M.tree:root()
end
M.next_heading = function()
  M.init()
  -- populate captures with all matching nodes from the next line to
  -- the last line of the buffer
  for _, node, _, _ in M.query:iter_captures(M.root, M.buffer, M.next_line, M.last_line) do
    table.insert(M.captures, node)
  end
  -- get the node at the specified index
  ts_utils.goto_node(M.captures[M.count])
end
M.previous_heading = function()
  M.init()
  -- if we are already at the top of the buffer
  -- there are no previous headings
  if M.current_line == M.first_line + 1 then
    return
  end
  -- populate captures with all matching nodes from the first line
  -- of the buffer to the previous line
  for _, node, _, _ in M.query:iter_captures(M.root, M.buffer, M.first_line, M.previous_line) do
    table.insert(M.captures, node)
  end
  -- get the node at the specified index
  ts_utils.goto_node(M.captures[#M.captures - M.count + 1])
end
-- define the keymaps
vim.keymap.set('n', 'J', M.next_heading)
vim.keymap.set('n', 'K', M.previous_heading)
