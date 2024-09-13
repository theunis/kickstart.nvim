local M = {}

local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values

M.buffer_connection_files = {}

function M.set_connection_file(bufnr, connection_file)
  M.buffer_connection_files[bufnr] = connection_file
end

function M.get_connection_file(bufnr)
  return M.buffer_connection_files[bufnr]
end

function M.get_connection_files()
  local poetry_venv = M.is_poetry_venv()
  local handle
  if poetry_venv then
    handle = io.popen 'poetry run jupyter --runtime-dir'
  else
    handle = io.popen 'jupyter --runtime-dir'
  end

  local runtime_dir = handle:read('*a'):gsub('\n', '')
  handle:close()

  local connection_files = {}
  for file in io.popen('ls ' .. runtime_dir .. '/kernel-*.json'):lines() do
    local attr = vim.loop.fs_stat(file)
    local modification_time = attr.mtime.sec
    table.insert(connection_files, { file = file, mtime = modification_time })
  end

  -- Sort files by modification time (latest first)
  table.sort(connection_files, function(a, b)
    return a.mtime > b.mtime
  end)

  return connection_files
end

function M.set_most_recent_connection_file(bufnr)
  local connection_files = M.get_connection_files()
  if #connection_files == 0 then
    return
  end
  local most_recent_connection_file = connection_files[#connection_files]
  M.set_connection_file(bufnr, most_recent_connection_file)
end

function M.select_connection_file(callback)
  local connection_files = M.get_connection_files()
  local results = {}
  for _, entry in ipairs(connection_files) do
    local date = os.date('%Y-%m-%d %H:%M:%S', entry.mtime)
    table.insert(results, { display = string.format('%s - %s', date, entry.file), file = entry.file })
  end

  pickers
    .new({}, {
      prompt_title = 'Select Jupyter Connection File',
      finder = finders.new_table {
        results = results,
        entry_maker = function(entry)
          return {
            value = entry.file,
            display = entry.display,
            ordinal = entry.file,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local bufnr = vim.api.nvim_get_current_buf()
          M.set_connection_file(bufnr, selection.value)
          print('Selected Jupyter Connection File: ' .. selection.value)
          if callback then
            callback(selection.value)
          end
        end)
        return true
      end,
    })
    :find()
end

function M.ensure_connection_file(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local connection_file = M.get_connection_file(bufnr)

  if not connection_file or #connection_file == 0 then
    print 'No Jupyter connection file set for this buffer. Please select one.'
    M.select_connection_file(callback)
  else
    if callback then
      callback(connection_file)
    end
  end
end

function M.init_molten()
  M.ensure_connection_file(function(connection_file)
    print(connection_file)
    vim.cmd('MoltenInit ' .. connection_file)
    print('Molten initialized with connection file: ' .. connection_file)
  end)
end

function M.get_connection_file_basename()
  local bufnr = vim.api.nvim_get_current_buf()
  local connection_file = M.get_connection_file(bufnr)

  if connection_file then
    return vim.fn.fnamemodify(connection_file, ':t')
  end
  return nil
end

function M.is_poetry_venv()
  local handle = io.popen 'poetry env info -p 2>/dev/null'
  if handle then
    local result = handle:read '*a'
    handle:close()
    return #result > 0
  else
    return false
  end
end

return M
