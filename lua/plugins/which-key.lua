return {
  'folke/which-key.nvim',
  lazy = false,
  opts = {},

  init = function()
    local function toggle_light_dark_theme()
      if vim.o.background == 'light' then
        vim.o.background = 'dark'
        vim.cmd [[Catppuccin mocha]]
      else
        vim.o.background = 'light'
        vim.cmd [[Catppuccin latte]]
      end
    end

    local function start_browser_sync()
      -- Command to check if the tmux session exists
      local check_session_cmd = 'tmux has-session -t altairchart 2>/dev/null'

      -- Command to create the tmux session and run browser-sync
      local create_session_cmd = 'tmux new-session -d -s altairchart \'cd ~/html/ && browser-sync start --server --no-open --files "*.html"\''

      -- Check if the 'browsersync' session already exists
      if os.execute(check_session_cmd) ~= 0 then
        -- The session does not exist, create it and run the command
        os.execute(create_session_cmd)
        os.execute "'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' --app='http://localhost:3000'"
      else
        -- The session exists, do nothing
        print "Tmux session 'altairchart' already exists."

        print 'Opening Chrome'
        os.execute "'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' --app='http://localhost:3000'"
      end
    end

    -- Function to update the Quarto code runner configuration dynamically
    local function set_quarto_code_runner(runner)
      local ok, quarto = pcall(require, 'quarto')
      if not ok then
        print 'Error: quarto.nvim plugin is not loaded.'
        return
      end

      local cfg_ok, cfg = pcall(require, 'quarto.config')
      if not cfg_ok then
        print 'Error: quarto.config module is not loaded.'
        return
      end

      -- Update the Quarto configuration directly
      if cfg.config and cfg.config.codeRunner then
        cfg.config.codeRunner.default_method = runner
        cfg.config.codeRunner.ft_runners.python = runner
        print('Quarto code runner set to ' .. runner)
      else
        print 'Error: Unable to access Quarto configuration.'
        return
      end

      -- Reinitialize the code runner commands
      if cfg.config.codeRunner.enabled then
        local runner_module = require 'quarto.runner'
        quarto.quartoSend = runner_module.run_cell
        quarto.quartoSendAbove = runner_module.run_above
        quarto.quartoSendBelow = runner_module.run_below
        quarto.quartoSendAll = runner_module.run_all
        quarto.quartoSendRange = runner_module.run_range
        quarto.quartoSendLine = runner_module.run_line

        -- Update user commands
        vim.api.nvim_create_user_command('QuartoSend', function(_)
          runner_module.run_cell()
        end, { force = true })
        vim.api.nvim_create_user_command('QuartoSendAbove', function(_)
          runner_module.run_above()
        end, { force = true })
        vim.api.nvim_create_user_command('QuartoSendBelow', function(_)
          runner_module.run_below()
        end, { force = true })
        vim.api.nvim_create_user_command('QuartoSendAll', function(_)
          runner_module.run_all()
        end, { force = true })
        vim.api.nvim_create_user_command('QuartoSendRange', function(_)
          runner_module.run_range()
        end, { range = 2, force = true })
        vim.api.nvim_create_user_command('QuartoSendLine', function(_)
          runner_module.run_line()
        end, { force = true })
      end
    end

    -- Function to get the Jupyter connection file
    local function get_jupyter_connection_file()
      local bufnr = vim.api.nvim_get_current_buf()
      local connection_file = require('jupyter_connection').get_connection_file(bufnr)
      if connection_file then
        return connection_file
      end
      return nil
    end

    -- Function to run df_explorer.sh with the connection file
    local function run_df_explorer()
      local connection_file = get_jupyter_connection_file()
      if connection_file then
        local command = string.format('tmux split-window -t 1 -h \'sh -c "~/dotfiles/df_explorer.sh --connection-file %s"\'', connection_file)
        print('Debug: Command to execute:', command)
        -- Execute the shell command
        local result = vim.fn.system(command)
        print('Debug: Command execution result:', result)
      else
        print 'No Jupyter connection file found.'
      end
    end

    -- -- Function to start browser-sync in a new terminal buffer
    -- local function start_browser_sync()
    --   -- Open a new terminal and run the command
    --   vim.cmd("terminal cd ~/html/ && browser-sync start --server --files '*.html'")
    --   -- Go back to the previous buffer
    --   vim.cmd("normal! <C-\\><C-n><C-^>")
    --   -- If you want to hide the terminal buffer instead of just switching away,
    --   -- you can use the following command
    --   vim.cmd("hide")
    -- end

    -- Define a Lua function to send code to the terminal, scroll down, and return to the original window
    local function send_to_terminal_and_scroll_down()
      vim.cmd 'QuartoSend'
      -- Save the current window
      local original_window = vim.api.nvim_get_current_win()
      -- Iterate through all windows
      local windows = vim.api.nvim_list_wins()
      for _, win in ipairs(windows) do
        local buf_type = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), 'buftype')
        if buf_type == 'terminal' then
          -- Switch to the terminal window
          vim.api.nvim_set_current_win(win)
          -- Scroll to the bottom
          vim.cmd 'normal! G'
          break
        end
      end
      -- Return to the original window
      vim.api.nvim_set_current_win(original_window)
    end

    local function send_dataframe_to_duckdb()
      -- Get the word under the cursor, assumed to be the DataFrame variable name
      local dataframe_name = vim.fn.expand '<cword>'
      local db_location = vim.fn.getcwd() .. '/default.duckdb'

      -- Construct the to_duckdb magic command with the DataFrame name
      local command = '%to_duckdb ' .. dataframe_name .. ' ' .. dataframe_name .. ' "' .. db_location .. '"\n'

      -- Send the command to IPython via vim-slime
      vim.fn['slime#send'](command)
    end

    local function send_dataframe_to_feather()
      -- Get the word under the cursor, assumed to be the DataFrame variable name
      local dataframe_name = vim.fn.expand '<cword>'

      -- Construct the to_feather magic command with the DataFrame name
      local command = '%to_feather ' .. dataframe_name .. ' ' .. dataframe_name .. '.feather\n'

      -- Send the command to IPython via vim-slime
      vim.fn['slime#send'](command)
    end

    local function execute_code_block_and_move()
      -- This is a placeholder for the command to execute the current block in vim-slime.
      -- You'll need to replace `<cmd>` with the actual command or sequence to execute the block.
      -- Send to terminal and scroll down:
      -- send_to_terminal_and_scroll_down()
      -- vim.cmd("QuartoSend")

      vim.api.nvim_exec('QuartoSend', false)

      -- Logic to move to the next code block after execution.
      -- This is highly simplified and needs to be replaced with actual logic to move to the next code block.
      -- For example, you might search for the next set of triple backticks in markdown.
      vim.cmd 'normal ]]'

      -- Optionally, move the cursor down one line if needed.
      vim.cmd 'normal! j'
    end

    local function feedkeys(key, mode)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
    end

    local function add_python_block_below()
      feedkeys('k][jo<esc>', 'n')
      vim.api.nvim_set_current_line '```{python}'
      feedkeys('o', 'n')
      vim.api.nvim_set_current_line '```'
      feedkeys('kO', 'n')
    end

    local function create_qmd_scratch_file()
      local datetime = os.date '%Y-%m-%d_%H-%M-%S'
      local filepath = vim.fn.expand './notebooks/dev/dev-' .. datetime .. '.qmd'
      local template_path = vim.fn.expand './notebooks/dev/dev-template.qmd'

      -- Ensure the directory exists
      vim.fn.mkdir(vim.fn.expand './notebooks/dev/', 'p')

      -- Copy the template file to the new file with datetime in its name
      vim.fn.system { 'cp', template_path, filepath }

      -- Open the new file
      vim.cmd('edit ' .. filepath)
    end

    local function quarto_conditional(command, otter_func)
      return function()
        if vim.bo.filetype == 'quarto' or vim.bo.filetype == 'qmd' then
          require('otter')[otter_func]()
        else
          vim.cmd(command)
        end
      end
    end

    local function create_tmux_pane(command, perc_height)
      perc_height = perc_height or 50
      -- Create new vertical split and get the pane id
      local pane_id = vim.fn.system("tmux split-window -v -P -F '#{pane_id}' -l '" .. perc_height .. "%' '" .. command .. "'")

      -- Check if the pane_id was successfully retrieved
      if pane_id == '' then
        return false
      end

      -- Use the pane id to set the vim-slime target pane
      vim.g.slime_default_config = { socket_name = 'default', target_pane = pane_id }

      return true
    end

    local function open_jupyter_console()
      local bufnr = vim.api.nvim_get_current_buf()
      local connection_file = require('jupyter_connection').get_connection_file(bufnr)
      local cmd

      -- Function to determine if Poetry is being used
      local function is_poetry_venv()
        local handle = io.popen 'poetry env info -p 2>/dev/null'
        if handle then
          local result = handle:read '*a'
          handle:close()
          return #result > 0
        else
          return false
        end
      end

      -- Determine the type of environment
      local poetry_venv = is_poetry_venv()
      local standard_venv = vim.env.VIRTUAL_ENV and #vim.env.VIRTUAL_ENV > 0
      local dot_venv = vim.fn.isdirectory '.venv' == 1

      if poetry_venv then
        vim.notify('Detected poetry env...', vim.log.levels.INFO)
      elseif standard_venv then
        vim.notify('Detected venv...', vim.log.levels.INFO)
      elseif dot_venv then
        vim.notify('Detected .venv...', vim.log.levels.INFO)
      else
        vim.notify('No env detected...', vim.log.levels.WARN)
      end

      if connection_file then
        cmd = 'jupyter console --existing ' .. connection_file
        vim.notify('Opening Jupyter console with existing connection file...', vim.log.levels.INFO)
      else
        if poetry_venv then
          local handle = io.popen 'poetry run jupyter kernelspec list'
          if handle then
            local result = handle:read '*a'
            handle:close()
            local kernel = vim.fn.fnamemodify(result, ':t')
            if result:find(kernel) then
              cmd = 'poetry run jupyter console --kernel=' .. kernel
            else
              vim.notify("Kernel '" .. kernel .. "' does not exist in Poetry environment.", vim.log.levels.ERROR)
              return
            end
          else
            vim.notify('Failed to check Jupyter kernels in Poetry environment.', vim.log.levels.ERROR)
            return
          end
        elseif dot_venv then
          -- Get the directory where the virtual environment is located
          local venv_path = vim.fn.fnamemodify('.venv', ':p:h:h')
          -- Get the basename of that directory
          local kernel = vim.fn.fnamemodify(venv_path, ':t')

          local handle = io.popen '.venv/bin/jupyter kernelspec list'
          if handle then
            local result = handle:read '*a'
            handle:close()
            if result:find(kernel) then
              cmd = '.venv/bin/jupyter console --kernel=' .. kernel
            else
              vim.notify("Kernel '" .. kernel .. "' does not exist in .venv.", vim.log.levels.ERROR)
              return
            end
          else
            vim.notify('Failed to check Jupyter kernels in .venv.', vim.log.levels.ERROR)
            return
          end
        elseif standard_venv then
          -- Get the directory where the virtual environment is located
          local venv_path = vim.fn.fnamemodify(vim.env.VIRTUAL_ENV, ':p:h:h')
          -- Get the basename of that directory
          local kernel = vim.fn.fnamemodify(venv_path, ':t')

          local handle = io.popen 'jupyter kernelspec list'
          if handle then
            local result = handle:read '*a'
            handle:close()
            -- if result:find(kernel) then
            cmd = 'source ' .. vim.env.VIRTUAL_ENV .. '/bin/activate && jupyter console --kernel=' .. kernel
            -- else
            --   vim.notify(
            --     "Kernel '" .. kernel .. "' does not exist in standard virtual environment.",
            --     vim.log.levels.ERROR
            --   )
            --   return
            -- end
          else
            vim.notify('Failed to check Jupyter kernels in standard virtual environment.', vim.log.levels.ERROR)
            return
          end
        else
          vim.notify('No virtual environment detected. Please activate your environment.', vim.log.levels.ERROR)
          return
        end
      end

      -- Check if create_tmux_pane is available
      if not create_tmux_pane then
        vim.notify('create_tmux_pane function is not available. Please check your setup.', vim.log.levels.ERROR)
        return
      end

      -- Execute the command in a tmux pane
      local success = create_tmux_pane(cmd, 30)
      if success then
        vim.notify('Jupyter console opened successfully in a new tmux pane.', vim.log.levels.INFO)
      else
        vim.notify('Failed to open Jupyter console in a new tmux pane.', vim.log.levels.ERROR)
      end
    end

    local mappings = {
      -- General keybindings
      { '<leader>', group = 'leader' },
      { '<S-CR>', execute_code_block_and_move, desc = 'Execute code block and move to next' },
      { '<leader><CR>', send_to_terminal_and_scroll_down, desc = 'Execute Code Chunk' },
      { '<leader>/', '<Cmd>Telescope current_buffer_fuzzy_find<CR>', desc = 'Fuzzy Buffer' },
      { '<leader>?', '<Cmd>Telescope help_tags<CR>', desc = 'Help Tags' },

      -- Grouped keybindings
      { '<leader>[', group = 'Previous' },
      { '<leader>[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', desc = 'Diagnostic' },
      { '<leader>]', group = 'Next' },
      { '<leader>]d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', desc = 'Diagnostic' },
      { '<leader>b', group = 'Buffer' },
      { '<leader>bb', '<Cmd>Telescope buffers<CR>', desc = 'Switch Buffer' },
      { '<leader>bk', '<Cmd>bd<CR>', desc = 'Kill Buffer' },
      { '<leader>bl', '<Cmd>ls<CR>', desc = 'List Buffers' },

      -- ChatGPT keybindings
      { '<leader>c', group = 'ChatGPT' },
      { '<leader>cc', '<cmd>ChatGPT<CR>', desc = 'ChatGPT' },
      { '<leader>ce', '<cmd>ChatGPTEditWithInstruction<CR>', desc = 'Edit with instruction', mode = { 'n', 'v' } },
      { '<leader>cg', '<cmd>ChatGPTRun grammar_correction<CR>', desc = 'Grammar Correction', mode = { 'n', 'v' } },
      { '<leader>ct', '<cmd>ChatGPTRun translate<CR>', desc = 'Translate', mode = { 'n', 'v' } },
      { '<leader>ck', '<cmd>ChatGPTRun keywords<CR>', desc = 'Keywords', mode = { 'n', 'v' } },
      { '<leader>cd', '<cmd>ChatGPTRun docstring<CR>', desc = 'Docstring', mode = { 'n', 'v' } },
      { '<leader>ca', '<cmd>ChatGPTRun add_tests<CR>', desc = 'Add Tests', mode = { 'n', 'v' } },
      { '<leader>co', '<cmd>ChatGPTRun optimize_code<CR>', desc = 'Optimize Code', mode = { 'n', 'v' } },
      { '<leader>cs', '<cmd>ChatGPTRun summarize<CR>', desc = 'Summarize', mode = { 'n', 'v' } },
      { '<leader>cf', '<cmd>ChatGPTRun fix_bugs<CR>', desc = 'Fix Bugs', mode = { 'n', 'v' } },
      { '<leader>cx', '<cmd>ChatGPTRun explain_code<CR>', desc = 'Explain Code', mode = { 'n', 'v' } },
      { '<leader>cr', '<cmd>ChatGPTRun roxygen_edit<CR>', desc = 'Roxygen Edit', mode = { 'n', 'v' } },
      { '<leader>cl', '<cmd>ChatGPTRun code_readability_analysis<CR>', desc = 'Code Readability Analysis', mode = { 'n', 'v' } },

      -- Debug keybindings
      { '<leader>d', group = 'Debug' },
      { '<leader>dc', "<Cmd>lua require'dap'.continue()<CR>", desc = 'Continue' },
      { '<leader>ds', "<Cmd>lua require'dap'.step_over()<CR>", desc = 'Step Over' },
      { '<leader>di', "<Cmd>lua require'dap'.step_into()<CR>", desc = 'Step Into' },
      { '<leader>do', "<Cmd>lua require'dap'.step_out()<CR>", desc = 'Step Out' },
      { '<leader>db', "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = 'Toggle Breakpoint' },
      { '<leader>dB', "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", desc = 'Conditional Breakpoint' },
      { '<leader>dl', "<Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", desc = 'Log Point' },
      { '<leader>dr', "<Cmd>lua require'dap'.repl.open()<CR>", desc = 'Open REPL' },
      { '<leader>da', "<Cmd>lua require'dap'.run_last()<CR>", desc = 'Run Last' },
      { '<leader>du', group = 'DAP UI' },
      { '<leader>dut', "<Cmd>lua require'dapui'.toggle()<CR>", desc = 'Toggle UI' },
      { '<leader>due', "<Cmd>lua require'dapui'.eval()<CR>", desc = 'Evaluate' },
      { '<leader>duE', "<Cmd>lua require'dapui'.eval(vim.fn.input('Eval expression: '))<CR>", desc = 'Evaluate Expression' },
      { '<leader>duh', "<Cmd>lua require'dapui'.hover()<CR>", desc = 'Hover Variables' },
      { '<leader>dus', "<Cmd>lua require'dapui'.scopes()<CR>", desc = 'Scopes' },
      { '<leader>duf', "<Cmd>lua require'dapui'.float_element()<CR>", desc = 'Float Element' },

      -- Execute keybindings
      { '<leader>e', group = 'Execute' },
      { '<leader>e<CR>', '<Plug>QuartoSendRange<CR>', desc = 'Send Region', mode = 'v' },

      -- File keybindings
      { '<leader>f', group = 'File' },
      { '<leader>ft', '<Cmd>NvimTreeToggle<CR>', desc = 'Toggle Tree' },
      { '<leader>ff', '<Cmd>NvimTreeFindFile<CR>', desc = 'Find File' },
      { '<leader>fr', '<Cmd>Telescope oldfiles<CR>', desc = 'Recent Files' },

      -- Go keybindings
      { '<leader>g', group = 'Go' },
      { '<leader>gF', '<Cmd>Lspsaga finder<CR>', desc = 'Finder' },
      { '<leader>gd', quarto_conditional('Lspsaga peek_definition', 'ask_definition'), desc = 'Peek/Ask Definition' },
      { '<leader>gD', quarto_conditional('Lspsaga goto_definition', 'ask_definition'), desc = 'Goto/Ask Definition' },
      { '<leader>gh', quarto_conditional('Lspsaga hover_doc', 'ask_hover'), desc = 'Hover Doc/Ask Hover' },

      -- LSP keybindings
      { '<leader>l', group = 'LSP' },
      { '<leader>la', quarto_conditional('Lspsaga code_action', 'ask_code_action'), desc = 'Code Action' },
      { '<leader>lc', '<Cmd>Lspsaga show_cursor_diagnostics<CR>', desc = 'Cursor Diagnostics' },
      { '<leader>lC', '<Cmd>Lspsaga show_line_diagnostics<CR>', desc = 'Line Diagnostics' },
      { '<leader>ld', "<cmd>lua require('trouble').toggle('document_diagnostics')<cr>", desc = 'Document Diagnostics' },
      { '<leader>lf', '<Cmd>Format<CR>', desc = 'Format' },
      { '<leader>lF', '<Cmd>lua vim.diagnostic.open_float()<CR>', desc = 'Floating Diagnostic' },
      { '<leader>ll', "<cmd>lua require('trouble').toggle()<cr>", desc = 'Toggle Trouble' },
      { '<leader>lL', "<cmd>lua require('trouble').toggle('loclist')<cr>", desc = 'Location List' },
      { '<leader>ln', '<Cmd>Lspsaga diagnostic_jump_next<CR>', desc = 'Next Diagnostic' },
      { '<leader>lo', '<Cmd>lua vim.diagnostic.setloclist()<CR>', desc = 'Diagnostic List' },
      { '<leader>lp', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', desc = 'Prev Diagnostic' },
      { '<leader>lq', "<cmd>lua require('trouble').toggle('quickfix')<cr>", desc = 'Quickfix' },
      { '<leader>lr', quarto_conditional('Lspsaga rename', 'ask_rename'), desc = 'Rename' },
      { '<leader>lw', "<cmd>lua require('trouble').toggle('workspace_diagnostics')<cr>", desc = 'Workspace Diagnostics' },

      -- Code Chunk keybindings
      { '<leader>o', group = 'Code Chunk' },
      { '<leader>oa', 'o# %%<cr>', desc = 'New code chunk below' },
      { '<leader>oA', 'O# %%<cr>', desc = 'New code chunk above' },
      { '<leader>ob', 'o```{bash}<cr>```<esc>O', desc = 'Bash code chunk' },
      { '<leader>or', 'o```{r}<cr>```<esc>O', desc = 'R code chunk' },
      { '<leader>op', 'o```{python}<cr>```<cr><esc>kO', desc = 'Python code chunk' },
      { '<leader>oo', add_python_block_below, desc = 'Python code chunk below' },
      { '<leader>oO', 'j[]kko```{python}<cr>```<cr><esc>O', desc = 'Python code chunk above', noremap = true },
      { '<leader>o-', 'o```<cr><cr>```{python}<esc>kkk', desc = 'Split cell' },

      -- Quarto keybindings
      { '<leader>q', group = 'Quarto' },
      { '<leader>qa', ':QuartoActivate<CR>', desc = 'Activate' },
      { '<leader>qp', ":lua require'quarto'.quartoPreview()<CR>", desc = 'Preview' },
      { '<leader>qq', ":lua require'quarto'.quartoClosePreview()<CR>", desc = 'Close Preview' },
      { '<leader>qh', ':QuartoHelp ', desc = 'Help' },
      { '<leader>qe', ":lua require'otter'.export()<CR>", desc = 'Export' },
      { '<leader>qE', ":lua require'otter'.export(true)<CR>", desc = 'Export Overwrite' },
      { '<leader>qr', group = 'Run' },
      { '<leader>qrr', ':QuartoSendAbove<CR>', desc = 'Run to Cursor' },
      { '<leader>qra', ':QuartoSendAll<CR>', desc = 'Run All' },
      { '<leader>qrb', ':QuartoSendBelow<CR>', desc = 'Run below' },
      { '<leader>qrl', ':QuartoSendLine<CR>', desc = 'Run line' },
      { '<leader>qc', create_qmd_scratch_file, desc = 'Create .qmd scratch file' },
      {
        '<leader>qm',
        function()
          set_quarto_code_runner 'molten'
        end,
        desc = 'Set Quarto runner to Molten',
        noremap = true,
        silent = true,
      },
      {
        '<leader>qs',
        function()
          set_quarto_code_runner 'slime'
        end,
        desc = 'Set Quarto runner to Slime',
        noremap = true,
        silent = true,
      },

      -- Register keybindings
      { '<leader>r', group = 'Register' },
      { '<leader>rf', send_dataframe_to_feather, desc = 'Save dataframe to Feather' },
      { '<leader>rd', send_dataframe_to_duckdb, desc = 'Save dataframe to DuckDB' },
      { '<leader>rw', ':vsplit term://vdsql default.duckdb<CR>', desc = 'Open DuckDB in Visidata' },
      { '<leader>rv', ':vsplit term://vd ./feather_data/<CR>', desc = 'Open Feather in Visidata' },

      -- Search keybindings
      { '<leader>s', group = 'Search' },
      { '<leader>ss', '<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>', desc = 'Workspace Symbols' },
      { '<leader>sg', '<Cmd>Telescope live_grep<CR>', desc = 'Grep Project' },
      { '<leader>sf', '<Cmd>Telescope find_files<CR>', desc = 'Find Files' },
      { '<leader>sn', '<Cmd>Telescope luasnip<CR>', desc = 'Snippets' },
      { '<leader>sh', '<Cmd>Telescope help_tags<CR>', desc = 'Help Tags' },
      {
        '<leader>sj',
        ':lua require("jupyter_connection").select_connection_file()<CR>',
        desc = 'Select Jupyter connection file',
        noremap = true,
        silent = true,
      },
      { '<leader>sk', '<Cmd>Telescope keymaps<CR>', desc = 'Keymaps' },
      { '<leader>so', '<Cmd>ObsidianQuickSwitch<CR>', desc = 'Obsidian notes' },
      { '<leader>sO', '<Cmd>ObsidianSearch<CR>', desc = 'Obsidian search' },
      { '<leader>st', '<Cmd>Telescope builtin<CR>', desc = 'Telescope' },
      { '<leader>sw', '<Cmd>Telescope grep_string<CR>', desc = 'Grep Word' },
      { '<leader>sd', '<Cmd>Telescope diagnostics<CR>', desc = 'Diagnostics' },
      { '<leader>s ', '<Cmd>Telescope buffers<CR>', desc = 'Buffers' },
      { '<leader>s.', '<Cmd>Telescope oldfiles<CR>', desc = 'Recent Files' },
      { '<leader>sr', '<Cmd>Telescope resume<CR>', desc = 'Resume' },

      -- Tools keybindings
      { '<leader>t', group = 'Tools' },
      { '<leader>tu', '<Cmd>UndotreeToggle<CR>', desc = 'Undo Tree' },
      { '<leader>ta', '<Cmd>AerialToggle!<CR>', desc = 'Aerial Outline' },
      { '<leader>tl', '<Cmd>Twilight<CR>', desc = 'Twilight' },
      { '<leader>tc', group = 'Github Copilot' },
      { '<leader>tcc', '<Cmd>lua require"copilot".complete()<CR>', desc = 'Complete' },
      { '<leader>tcd', '<Cmd>Copilot disable<CR>', desc = 'Disable' },
      { '<leader>tce', '<Cmd>Copilot enable<CR>', desc = 'Enable' },
      { '<leader>tcs', '<Cmd>lua require"copilot".suggest()<CR>', desc = 'Suggest' },
      { '<leader>tf', group = 'Flutter' },
      { '<leader>tfc', '<Cmd>Telescope flutter commands<CR>', desc = 'Flutter' },
      { '<leader>tfd', '<Cmd>FlutterDevices<CR>', desc = 'Devices' },
      { '<leader>tfe', '<Cmd>FlutterEmulators<CR>', desc = 'Emulators' },
      { '<leader>tfl', '<Cmd>FlutterReload<CR>', desc = 'Hot Reload' },
      { '<leader>tfs', '<Cmd>FlutterRestart<CR>', desc = 'Hot Restart' },
      { '<leader>tft', '<Cmd>FlutterTest<CR>', desc = 'Run Tests' },
      { '<leader>tfr', '<Cmd>FlutterRun<CR>', desc = 'Run' },
      { '<leader>tg', group = 'Git' },
      { '<leader>tgb', '<Cmd>Telescope git_branches<CR>', desc = 'Branches' },
      { '<leader>tgc', '<Cmd>Telescope git_commits<CR>', desc = 'Commits' },
      { '<leader>tgf', '<Cmd>Telescope git_files<CR>', desc = 'Files' },
      { '<leader>tgg', '<Cmd>Git<CR>', desc = 'Git' },
      { '<leader>tgs', '<Cmd>Telescope git_status<CR>', desc = 'Status' },
      { '<leader>tm', group = 'Molten' },
      { '<leader>tmb', '<Cmd>MoltenEvaluateOperator<CR>', desc = 'Run operator selection' },
      { '<leader>tmc', '<Cmd>MoltenReevaluateCell<CR>', desc = 'Re-evaluate cell' },
      { '<leader>tmd', '<Cmd>MoltenDelete<CR>', desc = 'Delete Cell', noremap = true, silent = true },
      { '<leader>tmD', '<Cmd>MoltenDeinit<CR>', desc = 'Molten Deinit' },
      { '<leader>tme', '<Cmd>MoltenEvaluateLine<CR>', desc = 'Evaluate Line' },
      { '<leader>tmh', '<Cmd>MoltenHideOutput<CR>', desc = 'Hide Output', noremap = true, silent = true },
      { '<leader>tmH', '<Cmd>MoltenShowOutput<CR>', desc = 'Show Output' },
      { '<leader>tmo', '<Cmd>noautocmd MoltenEnterOutput<CR>', desc = 'Show/Enter Output', noremap = true, silent = true },
      { '<leader>tmi', ':lua require("jupyter_connection").init_molten()<CR>', desc = 'Molten Init with Jupyter connection', noremap = true, silent = true },
      { '<leader>tmI', '<Cmd>MoltenInterrupt<CR>', desc = 'Molten Interrupt' },
      { '<leader>tmn', '<Cmd>MoltenInfo<CR>', desc = 'Molten Info' },
      { '<leader>tmr', '<Cmd>MoltenOpenInBrowser<CR>', desc = 'Open in Browser' },
      { '<leader>tms', '<Cmd>MoltenSave<CR>', desc = 'Save output to json' },
      { '<leader>tml', '<Cmd>MoltenLoad<CR>', desc = 'Load output from json' },
      { '<leader>tmv', '<Cmd>SlimeConfig<CR>', desc = 'Slime configuration' },
      { '<leader>to', group = 'Obsidian' },
      { '<leader>to#', '<Cmd>ObsidianTags<CR>', desc = 'Tags' },
      { '<leader>tob', '<Cmd>ObsidianBacklinks<CR>', desc = 'Backlinks' },
      { '<leader>tod', '<Cmd>ObsidianDailies<CR>', desc = 'Dailies' },
      { '<leader>tof', '<Cmd>ObsidianFollowLink<CR>', desc = 'Follow link' },
      { '<leader>toF', '<Cmd>ObsidianFollowLink vsplit<CR>', desc = 'Follow link in vertical split' },
      { '<leader>tog', '<Cmd>ObsidianToggleCheckbox<CR>', desc = 'Toggle checkbox' },
      { '<leader>toi', '<Cmd>ObsidianPasteImg<CR>', desc = 'Paste image' },
      { '<leader>toL', '<Cmd>ObsidianLinks<CR>', desc = 'Links in current buffer' },
      { '<leader>tom', '<Cmd>ObsidianTomorrow<CR>', desc = "Tomorrow's note" },
      { '<leader>ton', '<Cmd>ObsidianNew<CR>', desc = 'New note' },
      { '<leader>too', '<Cmd>ObsidianOpen<CR>', desc = 'Open in Obsidian' },
      { '<leader>tot', '<Cmd>ObsidianToday<CR>', desc = "Today's note" },
      { '<leader>toT', '<Cmd>ObsidianTemplate<CR>', desc = 'Insert template' },
      { '<leader>toy', '<Cmd>ObsidianYesterday<CR>', desc = "Yesterday's note" },
      { '<leader>tow', '<Cmd>ObsidianWorkspace<CR>', desc = 'Switch workspace' },
      { '<leader>ts', group = 'Neotest' },
      { '<leader>tsa', ":lua require('neotest').run.run({ suite = true })<CR>", desc = 'Run All Tests' },
      { '<leader>tsd', ":lua require('neotest').run.run({strategy = 'dap'})", desc = 'Debug Test' },
      { '<leader>tsn', ":lua require('neotest').run.run()<CR>", desc = 'Run Nearest Test' },
      { '<leader>tsf', ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>", desc = 'Run Tests in File' },
      { '<leader>tsj', ":lua require('neotest').diagnostic.goto_next()<CR>", desc = 'Next Failed Test' },
      { '<leader>tsk', ":lua require('neotest').diagnostic.goto_prev()<CR>", desc = 'Previous Failed Test' },
      { '<leader>tsl', ":lua require('neotest').run.run_last()<CR>", desc = 'Run Last Test' },
      { '<leader>tso', ":lua require('neotest').output.open()<CR>", desc = 'Open Output' },
      { '<leader>tss', ":lua require('neotest').summary.toggle()<CR>", desc = 'Toggle Summary' },
      { '<leader>tt', group = 'Terminal' },
      {
        '<leader>ttI',
        function()
          create_tmux_pane('ipython --profile terminal', 30)
        end,
        desc = 'IPython Terminal',
      },
      {
        '<leader>ttJ',
        function()
          create_tmux_pane('source venv/bin/activate && jupyter console --kernel=$(basename $VIRTUAL_ENV)', 30)
        end,
        desc = 'Jupyter Console (basename)',
      },
      { '<leader>ttb', start_browser_sync, desc = 'Start browser-sync on ~/html', silent = true },
      { '<leader>tti', open_jupyter_console, desc = 'Jupyter Console' },
      { '<leader>ttj', ':split term://julia<CR>', desc = 'Julia Terminal' },
      { '<leader>ttp', ':split term://python<CR>', desc = 'Python Terminal' },
      { '<leader>ttr', ':split term://R<CR>', desc = 'R Terminal' },
      { '<leader>ttt', '<Cmd>lua require("FTerm").toggle()<CR>', desc = 'Toggle Terminal (Ctrl-`)' },
      { '<leader>ttv', run_df_explorer, desc = 'DataFrame Explorer' },

      -- Workspace keybindings
      { '<leader>w', group = 'Workspace' },
      { '<leader>ws', ':SessionSave<CR>', desc = 'Save Session' },
      { '<leader>wl', ':SessionRestore<CR>', desc = 'Load Session' },

      -- Advanced keybindings
      { '<leader>z', group = 'Advanced' },
      { '<leader>zl', group = 'Learn' },
      { '<leader>zld', '<Cmd>help<CR>', desc = 'Neovim Docs' },
      { '<leader>zlh', '<Cmd>Telescope help_tags<CR>', desc = 'Help Tags' },
      { '<leader>zs', group = 'System & Env' },
      { '<leader>zse', ':Telescope find_files cwd=~/.config/nvim/<CR>', desc = 'Edit Config' },
      { '<leader>zsv', '<Cmd>source $MYVIMRC<CR>', desc = 'Reload Config' },
      { '<leader>zst', toggle_light_dark_theme, desc = 'Switch theme' },
      { '<leader>zss', require('luasnip.loaders').edit_snippet_files, desc = 'Open snippets' },
      { '<leader>zz', '<Cmd>ZenMode<CR>', desc = 'Zen Mode' },

      -- Navigation keybindings
      { '[', group = 'Previous' },
      { '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', desc = 'Diagnostic' },
      { '[c', '<Cmd>MoltenPrev<CR>', desc = 'Code chunk' },
      { ']', group = 'Next' },
      { ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', desc = 'Diagnostic' },
      { ']c', '<Cmd>MoltenNext<CR>', desc = 'Code chunk' },

      -- Visual mode keybindings
      {
        mode = { 'v' },
        { '<leader>t', group = 'Tools' },
        { '<leader>to', group = 'Obsidian' },
        { '<leader>toN', '<Cmd>ObsidianLinkNew<CR>', desc = 'Insert link and create new note' },
        { '<leader>toe', '<Cmd>ObsidianExtractNote<CR>', desc = 'Extract text and create note' },
        { '<leader>tol', '<Cmd>ObsidianLink<CR>', desc = 'Insert link' },
      },
    }

    local wk = require 'which-key'

    local is_code_chunk = function()
      local current, _ = require('otter.keeper').get_current_language_context()
      return current ~= nil
    end

    local insert_code_chunk = function(lang)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
      local keys = is_code_chunk() and [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]] or [[o```{]] .. lang .. [[}<cr>```<esc>O]]
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
    end

    local insert_r_chunk = function()
      insert_code_chunk 'r'
    end

    local insert_py_chunk = function()
      insert_code_chunk 'python'
    end

    wk.add({
      { '<c-cr>', ':SlimeSend<CR>', desc = 'Send Code Chunk' },
      { '<m-i>', insert_r_chunk, desc = 'R code chunk' },
      { '<cm-i>', insert_py_chunk, desc = 'Python code chunk' },
      { '<m-I>', insert_py_chunk, desc = 'Python code chunk' },
      {
        '<C-p>',
        function()
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('[[', true, false, true), 'x')
          local current_pos = vim.api.nvim_win_get_cursor(0)
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes(']]', true, false, true), 'x')
          local new_pos = vim.api.nvim_win_get_cursor(0)
          if current_pos[1] < new_pos[1] then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('[[', true, false, true), 'x')
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('[[', true, false, true), 'x')
          else
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('[[', true, false, true), 'x')
          end
          vim.cmd 'normal! j'
        end,
        desc = 'Previous code chunk',
      },
      {
        '<C-n>',
        function()
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes(']]j', true, false, true), '')
        end,
        desc = 'Next code chunk',
      },
    }, { mode = 'n' })

    wk.add({
      { '<c-cr>', '<esc>:SlimeSend<CR>i', desc = 'Send Code Chunk' },
      { '<m-i>', insert_r_chunk, desc = 'R code chunk' },
      { '<cm-i>', insert_py_chunk, desc = 'Python code chunk' },
      { '<m-I>', insert_py_chunk, desc = 'Python code chunk' },
    }, { mode = 'i' })

    wk.add {
      { '<c-cr>', '<Plug>SlimeRegionSend<CR>', desc = 'Send Code Chunk', mode = 'v' },
    }

    -- Register the mappings with which-key
    wk.add(mappings)
  end,
}
