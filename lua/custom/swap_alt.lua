local M = {}

local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'
-- local shared = require 'nvim-treesitter.textobjects.shared'
local shared = require 'custom.shared_alt'
local attach = require 'nvim-treesitter.textobjects.attach'

--- Gets the injected language at the cursor position.
-- If the cursor is not within an injected language, returns nil.
-- @return string|nil, language name if found or nil otherwise
function M.get_injected_language_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- Convert to 0-based indexing for Tree-sitter

  -- Get the root parser for the current buffer
  local parser = parsers.get_parser(bufnr)
  if not parser then
    return nil, 'No parser available for this buffer'
  end

  -- Iterate through all language trees, including injected languages
  local lang_tree = parser:language_for_range { cursor_row, cursor_col, cursor_row, cursor_col }
  if not lang_tree then
    return nil, 'No language tree found at the cursor position'
  end

  -- Identify if this node represents an injected language
  local injected = parser:language_for_range { cursor_row, cursor_col, cursor_row, cursor_col }
  if injected then
    local language = injected:lang()
    return language
  else
    return nil, 'Cursor is not within an injected code block'
  end
end

local function swap_textobject(query_strings_regex, query_group, direction)
  query_strings_regex = shared.make_query_strings_table(query_strings_regex)
  query_group = query_group or 'textobjects'

  local lang = M.get_injected_language_at_cursor()
  print(lang)

  local query_strings = shared.get_query_strings_from_regex(query_strings_regex, query_group, lang)

  local bufnr, textobject_range, node, query_string
  for _, query_string_iter in ipairs(query_strings) do
    print(query_string_iter)
    bufnr, textobject_range, node = shared.textobject_at_point(query_string_iter, query_group)
    print(node)
    if node then
      query_string = query_string_iter
      break
    end
  end
  print(query_string)
  if not query_string then
    return
  end

  local step = direction > 0 and 1 or -1
  local overlapping_range_ok = false
  local same_parent = true
  for _ = 1, math.abs(direction), step do
    local forward = direction > 0
    local adjacent, metadata = shared.get_adjacent(forward, node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
    print '-----'
    print(adjacent)
    ts_utils.swap_nodes(textobject_range, metadata and metadata.range or adjacent, bufnr, 'yes, set cursor!')
  end
end

function M.swap_next(query_strings_regex, query_group)
  swap_textobject(query_strings_regex, query_group, 1)
end

function M.swap_previous(query_strings_regex, query_group)
  swap_textobject(query_strings_regex, query_group, -1)
end

local normal_mode_functions = { 'swap_next', 'swap_previous' }

M.attach = attach.make_attach(normal_mode_functions, 'swap', 'n', { dot_repeatable = true })
M.detach = attach.make_detach 'swap'

M.commands = {
  TSTextobjectSwapNext = {
    run = M.swap_next,
    args = {
      '-nargs=1',
      '-complete=custom,nvim_treesitter_textobjects#available_textobjects',
    },
  },
  TSTextobjectSwapPrevious = {
    run = M.swap_previous,
    args = {
      '-nargs=1',
      '-complete=custom,nvim_treesitter_textobjects#available_textobjects',
    },
  },
}

return M
