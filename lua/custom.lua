local function insert_python_list_from_selections()
  local selected_items = {}
  -- Using Telescope to select multiple items
  require('telescope.pickers')
    .new({}, {
      prompt_title = 'Select Items',
      finder = require('telescope.finders').new_table {
        results = { 'item1', 'item2', 'item3', 'item4' }, -- Your items here
      },
      sorter = require('telescope.config').values.generic_sorter {},
      attach_mappings = function(_, map)
        map('i', '<CR>', function(prompt_bufnr)
          local selection = require('telescope.actions.state').get_selected_entry()
          table.insert(selected_items, selection[1])
          require('telescope.actions').close(prompt_bufnr)
        end)
        return true
      end,
    })
    :find()
  -- Convert the selected items to a Python list and insert into the buffer
  vim.schedule(function()
    local python_list = 'selected_items = [' .. table.concat(selected_items, ', ') .. ']'
    vim.api.nvim_put({ python_list }, 'l', true, true)
  end)
end

vim.api.nvim_create_user_command('InsertPythonList', insert_python_list_from_selections, { desc = 'Insert a Python list from selected items' })
