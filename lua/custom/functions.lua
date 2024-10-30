local function insert_python_list_from_selections()
  local selected_items = {}
  -- Using Telescope to select multiple items
  require("telescope.pickers")
    .new({}, {
      prompt_title = "Select Items",
      finder = require("telescope.finders").new_table({
        results = { "item1", "item2", "item3", "item4" }, -- Your items here
      }),
      sorter = require("telescope.config").values.generic_sorter({}),
      attach_mappings = function(_, map)
        map("i", "<CR>", function(prompt_bufnr)
          local selection = require("telescope.actions.state").get_selected_entry()
          if selection then
            table.insert(selected_items, selection.value)
          end
          require("telescope.actions").close(prompt_bufnr)
        end)
        return true
      end,
    })
    :find()
  -- Convert the selected items to a Python list and insert into the buffer
  vim.schedule(function()
    local python_list = "selected_items = [" .. table.concat(selected_items, ", ") .. "]"
    vim.api.nvim_put({ python_list }, "l", true, true)
  end)
end

vim.api.nvim_create_user_command(
  "InsertPythonList",
  insert_python_list_from_selections,
  { desc = "Insert a Python list from selected items" }
)

local M = {}

function M.toggle_light_dark_theme()
  if vim.o.background == "light" then
    vim.o.background = "dark"
    vim.cmd([[Catppuccin mocha]])
  else
    vim.o.background = "light"
    vim.cmd([[Catppuccin latte]])
  end
end

function M.start_browser_sync()
  -- Command to check if the tmux session exists
  local check_session_cmd = "tmux has-session -t altairchart 2>/dev/null"

  -- Command to create the tmux session and run browser-sync
  local create_session_cmd =
    "tmux new-session -d -s altairchart 'cd ~/html/ && browser-sync start --server --no-open --files \"*.html\"'"

  -- Check if the 'browsersync' session already exists
  if os.execute(check_session_cmd) ~= 0 then
    -- The session does not exist, create it and run the command
    os.execute(create_session_cmd)
    os.execute("'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' --app='http://localhost:3000'")
  else
    -- The session exists, do nothing
    print("Tmux session 'altairchart' already exists.")

    print("Opening Chrome")
    os.execute("'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' --app='http://localhost:3000'")
  end
end

function M.open_jupyter_console()
  local bufnr = vim.api.nvim_get_current_buf()
  local jupyter_connection = require("custom.jupyter_connection")
  local connection_file = jupyter_connection.get_connection_file(bufnr)
  local cmd

  -- Function to determine if Poetry is being used
  local function is_poetry_venv()
    local handle = io.popen("poetry env info -p 2>/dev/null")
    if handle then
      local result = handle:read("*a")
      handle:close()
      return #result > 0
    else
      return false
    end
  end

  -- Determine the type of environment
  local poetry_venv = is_poetry_venv()
  local standard_venv = vim.env.VIRTUAL_ENV and #vim.env.VIRTUAL_ENV > 0
  local dot_venv = vim.fn.isdirectory(".venv") == 1

  if poetry_venv then
    vim.notify("Detected poetry env...", vim.log.levels.INFO)
  elseif standard_venv then
    vim.notify("Detected venv...", vim.log.levels.INFO)
  elseif dot_venv then
    vim.notify("Detected .venv...", vim.log.levels.INFO)
  else
    vim.notify("No env detected...", vim.log.levels.WARN)
  end

  if connection_file and #connection_file > 0 then
    cmd = "jupyter console --existing " .. connection_file
    vim.notify("Opening Jupyter console with existing connection file...", vim.log.levels.INFO)
  else
    if poetry_venv then
      -- Get the directory where the poetry.lock file is located
      local poetry_path = vim.fn.fnamemodify("poetry.lock", ":p:h")
      -- Get the basename of that directory
      local kernel = vim.fn.fnamemodify(poetry_path, ":t")

      local handle = io.popen("poetry run jupyter kernelspec list")
      if handle then
        local result = handle:read("*a")
        handle:close()

        -- Trim whitespace from the kernel name
        kernel = kernel:match("^%s*(.-)%s*$")

        -- Check if the kernel is in the result
        local pattern = kernel:gsub("%-", "%%-") -- Escape hyphens for pattern matching
        local found = result:match(pattern)

        if found then
          cmd = "poetry run jupyter console --kernel=" .. kernel
        else
          vim.notify("Kernel '" .. kernel .. "' does not exist in Poetry environment.", vim.log.levels.ERROR)
          return
        end
      else
        vim.notify("Failed to check Jupyter kernels in Poetry environment.", vim.log.levels.ERROR)
        return
      end
    elseif dot_venv then
      -- Get the directory where the virtual environment is located
      local venv_path = vim.fn.fnamemodify(".venv", ":p:h:h")
      -- Get the basename of that directory
      local kernel = vim.fn.fnamemodify(venv_path, ":t")

      local handle = io.popen(".venv/bin/jupyter kernelspec list")
      if handle then
        local result = handle:read("*a")
        handle:close()
        if result:find(kernel) then
          cmd = ".venv/bin/jupyter console --kernel=" .. kernel
        else
          vim.notify("Kernel '" .. kernel .. "' does not exist in .venv.", vim.log.levels.ERROR)
          return
        end
      else
        vim.notify("Failed to check Jupyter kernels in .venv.", vim.log.levels.ERROR)
        return
      end
    elseif standard_venv then
      -- Get the directory where the virtual environment is located
      local venv_path = vim.fn.fnamemodify(vim.env.VIRTUAL_ENV, ":p:h:h")
      -- Get the basename of that directory
      local kernel = vim.fn.fnamemodify(venv_path, ":t")

      local handle = io.popen("jupyter kernelspec list")
      if handle then
        local result = handle:read("*a")
        handle:close()
        -- if result:find(kernel) then
        cmd = "source " .. vim.env.VIRTUAL_ENV .. "/bin/activate && jupyter console --kernel=" .. kernel
        -- else
        --   vim.notify(
        --     "Kernel '" .. kernel .. "' does not exist in standard virtual environment.",
        --     vim.log.levels.ERROR
        --   )
        --   return
        -- end
      else
        vim.notify("Failed to check Jupyter kernels in standard virtual environment.", vim.log.levels.ERROR)
        return
      end
    else
      vim.notify("No virtual environment detected. Please activate your environment.", vim.log.levels.ERROR)
      return
    end
    jupyter_connection.set_most_recent_connection_file(bufnr)
  end

  -- Check if create_tmux_pane is available
  if not M.create_tmux_pane then
    vim.notify("create_tmux_pane function is not available. Please check your setup.", vim.log.levels.ERROR)
    return
  end

  -- Execute the command in a tmux pane
  local success = M.create_tmux_pane(cmd, 30)
  if success then
    vim.notify(cmd)
    vim.notify("Jupyter console opened successfully in a new tmux pane.", vim.log.levels.INFO)
  else
    vim.notify("Failed to open Jupyter console in a new tmux pane.", vim.log.levels.ERROR)
  end
end

function M.create_tmux_pane(command, perc_height)
  perc_height = perc_height or 50
  -- Create new vertical split and get the pane id
  local pane_id =
    vim.fn.system("tmux split-window -v -P -F '#{pane_id}' -l '" .. perc_height .. "%' '" .. command .. "'")

  -- Check if the pane_id was successfully retrieved
  if pane_id == "" then
    return false
  end

  -- Use the pane id to set the vim-slime target pane
  vim.g.slime_default_config = { socket_name = "default", target_pane = pane_id }

  return true
end

-- Function to update the Quarto code runner configuration dynamically
function M.set_quarto_code_runner(runner)
  local ok, quarto = pcall(require, "quarto")
  if not ok then
    print("Error: quarto.nvim plugin is not loaded.")
    return
  end

  local cfg_ok, cfg = pcall(require, "quarto.config")
  if not cfg_ok then
    print("Error: quarto.config module is not loaded.")
    return
  end

  -- Update the Quarto configuration directly
  if cfg.config and cfg.config.codeRunner then
    cfg.config.codeRunner.default_method = runner
    cfg.config.codeRunner.ft_runners.python = runner
    print("Quarto code runner set to " .. runner)
  else
    print("Error: Unable to access Quarto configuration.")
    return
  end

  -- Reinitialize the code runner commands
  if cfg.config.codeRunner.enabled then
    local runner_module = require("quarto.runner")
    quarto.quartoSend = runner_module.run_cell
    quarto.quartoSendAbove = runner_module.run_above
    quarto.quartoSendBelow = runner_module.run_below
    quarto.quartoSendAll = runner_module.run_all
    quarto.quartoSendRange = runner_module.run_range
    quarto.quartoSendLine = runner_module.run_line

    -- Update user commands
    vim.api.nvim_create_user_command("QuartoSend", function(_)
      runner_module.run_cell()
    end, { force = true })
    vim.api.nvim_create_user_command("QuartoSendAbove", function(_)
      runner_module.run_above()
    end, { force = true })
    vim.api.nvim_create_user_command("QuartoSendBelow", function(_)
      runner_module.run_below()
    end, { force = true })
    vim.api.nvim_create_user_command("QuartoSendAll", function(_)
      runner_module.run_all()
    end, { force = true })
    vim.api.nvim_create_user_command("QuartoSendRange", function(_)
      runner_module.run_range()
    end, { range = 2, force = true })
    vim.api.nvim_create_user_command("QuartoSendLine", function(_)
      runner_module.run_line()
    end, { force = true })
  end
end

-- Function to run df_explorer.sh with the connection file
function M.run_df_explorer()
  local jupyter_connection = require("custom.jupyter_connection")
  local connection_file = jupyter_connection.get_jupyter_connection_file()
  if connection_file then
    local command = string.format(
      "tmux split-window -t 1 -h 'sh -c \"python ~/dotfiles/df_explorer.py --connection-file %s\"'",
      connection_file
    )
    print("Debug: Command to execute:" .. command)
    -- Execute the shell command
    local result = vim.fn.system(command)
    print("Debug: Command execution result:" .. result)
  else
    print("No Jupyter connection file found.")
  end
end

-- Define a Lua function to send code to the terminal, scroll down, and return to the original window
function M.send_to_terminal_and_scroll_down()
  vim.cmd("QuartoSend")
  -- Save the current window
  local original_window = vim.api.nvim_get_current_win()
  -- Iterate through all windows
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    local buf_type = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "buftype")
    if buf_type == "terminal" then
      -- Switch to the terminal window
      vim.api.nvim_set_current_win(win)
      -- Scroll to the bottom
      vim.cmd("normal! G")
      break
    end
  end
  -- Return to the original window
  vim.api.nvim_set_current_win(original_window)
end

function M.execute_code_block_and_move()
  -- This is a placeholder for the command to execute the current block in vim-slime.
  -- You'll need to replace `<cmd>` with the actual command or sequence to execute the block.
  -- Send to terminal and scroll down:
  -- send_to_terminal_and_scroll_down()
  -- vim.cmd("QuartoSend")

  vim.api.nvim_exec("QuartoSend", false)

  -- add mark for last executed code block
  vim.cmd("normal ml")

  -- Logic to move to the next code block after execution.
  vim.cmd("normal ]]")
end

function M.combine_code_block()
  vim.api.nvim_exec("TS", false)

  -- add mark for last executed code block
  vim.cmd("normal ml")

  -- Logic to move to the next code block after execution.
  vim.cmd("normal ]]")
end

function M.add_python_block_below()
  local function feedkeys(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end
  feedkeys("k][jo<esc>", "n")
  vim.api.nvim_set_current_line("```{python}")
  feedkeys("o", "n")
  vim.api.nvim_set_current_line("```")
  feedkeys("kO", "n")
end

function M.create_qmd_scratch_file()
  local datetime = os.date("%Y-%m-%d_%H-%M-%S")
  local filepath = vim.fn.expand("./notebooks/dev/dev-") .. datetime .. ".qmd"
  local template_path = vim.fn.expand("./notebooks/dev/dev-template.qmd")

  -- Ensure the directory exists
  vim.fn.mkdir(vim.fn.expand("./notebooks/dev/"), "p")

  -- Copy the template file to the new file with datetime in its name
  vim.fn.system({ "cp", template_path, filepath })

  -- Open the new file
  vim.cmd("edit " .. filepath)
end

-- Function to go to the next code block
function M.goto_next_code_block()
  local ts = vim.treesitter
  local parser = ts.get_parser(0, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = ts.query.parse("markdown", "(fenced_code_block) @code_block")

  local code_blocks = {}
  for _, node in query:iter_captures(root, 0) do
    local start_row, _, _ = node:start()
    table.insert(code_blocks, { node = node, start_row = start_row })
  end

  local current_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local next_block = nil
  local min_row = math.huge

  for _, block in ipairs(code_blocks) do
    if block.start_row > current_row and block.start_row < min_row then
      min_row = block.start_row
      next_block = block
    end
  end

  if next_block then
    local code_fence_content = nil
    for child in next_block.node:iter_children() do
      if child:type() == "code_fence_content" then
        code_fence_content = child
        break
      end
    end
    if code_fence_content then
      local content_start_row, content_start_col = code_fence_content:start()
      vim.api.nvim_win_set_cursor(0, { content_start_row + 1, content_start_col })
    else
      vim.api.nvim_win_set_cursor(0, { next_block.start_row + 1, 0 })
    end
  else
    print("No next code block found")
  end
end

-- Function to go to the previous code block
function M.goto_previous_code_block()
  local ts = vim.treesitter
  local parser = ts.get_parser(0, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = ts.query.parse("markdown", "(fenced_code_block) @code_block")

  local code_blocks = {}
  for _, node in query:iter_captures(root, 0) do
    local start_row, _ = node:start()
    local end_row, _ = node:end_()
    table.insert(code_blocks, { node = node, start_row = start_row, end_row = end_row })
  end

  local current_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local prev_block = nil
  local start_row_prev_block = -1

  for _, block in ipairs(code_blocks) do
    local first_line_of_block_is_before_cursor = block.start_row < current_row
    local first_line_of_block_is_after_first_line_of_prev_block = block.start_row > start_row_prev_block
    local cursor_not_within_code_block = current_row > block.end_row

    if
      first_line_of_block_is_before_cursor
      and first_line_of_block_is_after_first_line_of_prev_block
      and cursor_not_within_code_block
    then
      -- Update first line of previous code block
      start_row_prev_block = block.start_row
      prev_block = block
    end
  end

  if prev_block then
    local code_fence_content = nil
    for child in prev_block.node:iter_children() do
      if child:type() == "code_fence_content" then
        code_fence_content = child
        break
      end
    end
    if code_fence_content then
      local content_start_row, content_start_col = code_fence_content:start()
      vim.api.nvim_win_set_cursor(0, { content_start_row + 1, content_start_col })
    else
      vim.api.nvim_win_set_cursor(0, { prev_block.start_row + 1, 0 })
    end
  else
    print("No previous code block found")
  end
end

-- Helper function to find the current code block or paragraph
local function get_current_node()
  local ts = vim.treesitter
  local parser = ts.get_parser(0, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()

  local current_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local current_col = vim.api.nvim_win_get_cursor(0)[2]

  -- Use vim.treesitter.get_node() for newer versions
  local node = ts.get_node({ pos = { current_row, current_col } })

  -- Walk up the tree until we find a code block or paragraph
  while node and node:type() ~= "fenced_code_block" and node:type() ~= "paragraph" do
    node = node:parent()
  end

  return node
end

-- Helper function to get text between positions
local function get_text_between(start_row, start_col, end_row, end_col)
  if start_row == end_row then
    local line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
    return { line:sub(start_col + 1, end_col) }
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
  lines[1] = lines[1]:sub(start_col + 1)
  lines[#lines] = lines[#lines]:sub(1, end_col)
  return lines
end

-- Helper function to get code block content
local function get_code_block_content(node)
  local content = {}
  for child in node:iter_children() do
    if child:type() == "code_fence_content" then
      local start_row, start_col, end_row, end_col = child:range()
      local lines = get_text_between(start_row, start_col, end_row, end_col)
      for i = 1, #lines do
        table.insert(content, lines[i])
      end
      return content
    end
  end
  return {}
end

-- Add a code block below current block
function M.add_code_block_below()
  local node = get_current_node()
  local insert_row

  if node then
    local _, _, end_row, _ = node:range()
    insert_row = end_row + 1
  else
    insert_row = vim.api.nvim_win_get_cursor(0)[1]
  end

  local lines = {
    "",
    "```{python}",
    "",
    "```",
    "",
  }

  vim.api.nvim_buf_set_lines(0, insert_row, insert_row, false, lines)
  vim.api.nvim_win_set_cursor(0, { insert_row + 3, 0 })
end

-- Add a code block above current block
function M.add_code_block_above()
  local node = get_current_node()
  local insert_row

  if node then
    local start_row, _, _, _ = node:range()
    insert_row = start_row
  else
    insert_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  end

  local lines = {
    "",
    "```{python}",
    "",
    "```",
    "",
  }

  vim.api.nvim_buf_set_lines(0, insert_row, insert_row, false, lines)
  vim.api.nvim_win_set_cursor(0, { insert_row + 3, 0 })
end

-- Merge with code block below
function M.merge_with_block_below()
  local current_node = get_current_node()
  if not current_node or current_node:type() ~= "fenced_code_block" then
    print("Not in a code block")
    return
  end

  local ts = vim.treesitter
  local parser = ts.get_parser(0, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = ts.query.parse("markdown", "(fenced_code_block) @code_block")

  -- Find the next code block
  local current_end_row = select(3, current_node:range())
  local next_block = nil
  local min_start_row = math.huge

  for _, node in query:iter_captures(root, 0) do
    local start_row = node:start()
    if start_row > current_end_row and start_row < min_start_row then
      min_start_row = start_row
      next_block = node
    end
  end

  if not next_block then
    print("No code block below")
    return
  end

  -- Get the content of both blocks
  local current_content = get_code_block_content(current_node)
  local next_content = get_code_block_content(next_block)

  -- Get the text between blocks
  local _, _, current_end_row, current_end_col = current_node:range()
  local next_start_row, next_start_col, _, _ = next_block:range()
  local between_text = get_text_between(current_end_row, current_end_col, next_start_row, next_start_col)

  -- Create merged content
  local merged_lines = {
    "```{python}",
  }

  -- Add current content
  for _, line in ipairs(current_content) do
    table.insert(merged_lines, line)
  end

  -- Add next content
  for _, line in ipairs(next_content) do
    table.insert(merged_lines, line)
  end

  table.insert(merged_lines, "```")

  -- Replace the range from start of current block to end of next block
  local current_start_row = select(1, current_node:range())
  local next_end_row = select(3, next_block:range())
  vim.api.nvim_buf_set_lines(0, current_start_row, next_end_row + 1, false, merged_lines)

  -- If there was text between blocks, add it above merged block
  if #between_text > 0 then
    vim.api.nvim_buf_set_lines(0, current_start_row, current_start_row, false, between_text)
  end
end

-- Merge with code block above
function M.merge_with_block_above()
  local current_node = get_current_node()
  if not current_node or current_node:type() ~= "fenced_code_block" then
    print("Not in a code block")
    return
  end

  local ts = vim.treesitter
  local parser = ts.get_parser(0, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = ts.query.parse("markdown", "(fenced_code_block) @code_block")

  -- Find the previous code block
  local current_start_row = current_node:start()
  local prev_block = nil
  local max_end_row = -1

  for _, node in query:iter_captures(root, 0) do
    local _, _, end_row, _ = node:range()
    if end_row < current_start_row and end_row > max_end_row then
      max_end_row = end_row
      prev_block = node
    end
  end

  if not prev_block then
    print("No code block above")
    return
  end

  -- Get the content of both blocks
  local current_content = get_code_block_content(current_node)
  local prev_content = get_code_block_content(prev_block)

  -- Get the text between blocks
  local _, _, prev_end_row, prev_end_col = prev_block:range()
  local current_start_row, current_start_col, _, _ = current_node:range()
  local between_text = get_text_between(prev_end_row, prev_end_col, current_start_row, current_start_col)

  -- Create merged content
  local merged_lines = {
    "```{python}",
  }

  -- Add previous content
  for _, line in ipairs(prev_content) do
    table.insert(merged_lines, line)
  end

  -- Add current content
  for _, line in ipairs(current_content) do
    table.insert(merged_lines, line)
  end

  table.insert(merged_lines, "```")

  -- Replace the range from start of previous block to end of current block
  local prev_start_row = select(1, prev_block:range())
  local current_end_row = select(3, current_node:range())
  vim.api.nvim_buf_set_lines(0, prev_start_row, current_end_row + 1, false, merged_lines)

  -- If there was text between blocks, add it above merged block
  if #between_text > 0 then
    vim.api.nvim_buf_set_lines(0, prev_start_row, prev_start_row, false, between_text)
  end
end

return M
