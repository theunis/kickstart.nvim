return {
  'folke/which-key.nvim',
  opts = {},
  lazy = false,
  init = function()
    local funcs = require 'custom.functions'

    local mappings = {
      -- General keybindings
      { '<leader>', group = 'leader' },
      { '<S-CR>', funcs.execute_code_block_and_move, desc = 'Execute code block and move to next' },
      { '<leader><CR>', funcs.send_to_terminal_and_scroll_down, desc = 'Execute Code Chunk' },
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

      -- CodeCompanion keybindings
      { '<leader>co', '<cmd>CodeCompanionActions<cr>', desc = 'CodeCompanion Actions', icon = '' }, -- Actions icon
      { '<leader>ct', '<cmd>CodeCompanionToggle<cr>', desc = 'CodeCompanion Toggle', icon = '' }, -- Toggle icon
      { '<leader>cc', '<cmd>CodeCompanion<cr>', desc = 'CodeCompanion', icon = '' }, -- CodeCompanion icon
      { '<leader>ca', '<cmd>CodeCompanionAdd<cr>', desc = 'CodeCompanion Add', icon = '' }, -- Add icon

      -- Debug keybindings
      { '<leader>d', group = 'Debug' },
      { '<leader>dc', "<Cmd>lua require'dap'.continue()<CR>", desc = 'Continue' },
      { '<leader>ds', "<Cmd>lua require'dap'.step_over()<CR>", desc = 'Step Over' },
      { '<leader>di', "<Cmd>lua require'dap'.step_into()<CR>", desc = 'Step Into' },
      { '<leader>do', "<Cmd>lua require'dap'.step_out()<CR>", desc = 'Step Out' },
      { '<leader>db', "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = 'Toggle Breakpoint' },
      {
        '<leader>dB',
        "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        desc = 'Conditional Breakpoint',
      },
      {
        '<leader>dl',
        "<Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
        desc = 'Log Point',
      },
      { '<leader>dr', "<Cmd>lua require'dap'.repl.open()<CR>", desc = 'Open REPL' },
      { '<leader>da', "<Cmd>lua require'dap'.run_last()<CR>", desc = 'Run Last' },
      { '<leader>du', group = 'DAP UI' },
      { '<leader>dut', "<Cmd>lua require'dapui'.toggle()<CR>", desc = 'Toggle UI' },
      { '<leader>due', "<Cmd>lua require'dapui'.eval()<CR>", desc = 'Evaluate' },
      {
        '<leader>duE',
        "<Cmd>lua require'dapui'.eval(vim.fn.input('Eval expression: '))<CR>",
        desc = 'Evaluate Expression',
      },
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
      { '<leader>gf', '<Cmd>Lspsaga finder<CR>', desc = 'Finder' },
      { '<leader>gd', 'Lspsaga peek_definition', desc = 'Peek/Ask Definition' },
      { '<leader>gD', 'Lspsaga goto_definition', desc = 'Goto/Ask Definition' },
      { '<leader>gh', 'Lspsaga hover_doc', desc = 'Hover Doc/Ask Hover' },
      { 'gd', 'Lspsaga goto_definition', desc = 'Goto/Ask Definition' },

      -- LSP keybindings
      { '<leader>l', group = 'LSP' },
      { '<leader>la', 'Lspsaga code_action', desc = 'Code Action' },
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
      { '<leader>lr', '<Cmd>Lspsaga rename<CR>', desc = 'Rename' },
      {
        '<leader>lw',
        "<cmd>lua require('trouble').toggle('workspace_diagnostics')<cr>",
        desc = 'Workspace Diagnostics',
      },

      -- Code Chunk keybindings
      { '<leader>o', group = 'Code Chunk' },
      { '<leader>oa', 'o# %%<cr>', desc = 'New code chunk below' },
      { '<leader>oA', 'O# %%<cr>', desc = 'New code chunk above' },
      { '<leader>ob', 'o```{bash}<cr>```<esc>O', desc = 'Bash code chunk' },
      { '<leader>or', 'o```{r}<cr>```<esc>O', desc = 'R code chunk' },
      { '<leader>op', 'o```{python}<cr>```<cr><esc>kO', desc = 'Python code chunk' },
      { '<leader>oo', funcs.add_python_block_below, desc = 'Python code chunk below' },
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
      { '<leader>qc', funcs.create_qmd_scratch_file, desc = 'Create .qmd scratch file' },
      {
        '<leader>qm',
        function()
          funcs.set_quarto_code_runner 'molten'
        end,
        desc = 'Set Quarto runner to Molten',
        noremap = true,
        silent = true,
      },
      {
        '<leader>qs',
        function()
          funcs.set_quarto_code_runner 'slime'
        end,
        desc = 'Set Quarto runner to Slime',
        noremap = true,
        silent = true,
      },

      -- Search keybindings
      { '<leader>s', group = 'Search' },
      { '<leader>ss', '<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>', desc = 'Workspace Symbols' },
      { '<leader>sg', '<Cmd>Telescope live_grep<CR>', desc = 'Grep Project' },
      { '<leader>sf', "<CMD>lua require('custom.telescope-config').project_files()<CR>", noremap = true, silent = true, desc = 'Find Files' },

      -- { '<leader>sf', '<Cmd>Telescope find_files<CR>', desc = 'Find Files' },
      { '<leader>sn', '<Cmd>Telescope luasnip<CR>', desc = 'Snippets' },
      { '<leader>sh', '<Cmd>Telescope help_tags<CR>', desc = 'Help Tags' },
      {
        '<leader>sj',
        ':lua require("custom.jupyter_connection").select_connection_file()<CR>',
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
      {
        '<leader>tmo',
        '<Cmd>noautocmd MoltenEnterOutput<CR>',
        desc = 'Show/Enter Output',
        noremap = true,
        silent = true,
      },
      {
        '<leader>tmi',
        ':lua require("custom.jupyter_connection").init_molten()<CR>',
        desc = 'Molten Init with Jupyter connection',
        noremap = true,
        silent = true,
      },
      { '<leader>tmI', '<Cmd>MoltenInterrupt<CR>', desc = 'Molten Interrupt' },
      { '<leader>tmn', '<Cmd>MoltenInfo<CR>', desc = 'Molten Info' },
      { '<leader>tmr', '<Cmd>MoltenOpenInBrowser<CR>', desc = 'Open in Browser' },
      { '<leader>tms', '<Cmd>MoltenSave<CR>', desc = 'Save output to json' },
      {
        '<leader>tmS',
        ":lua require('custom.jupyter_connection').select_connection_file()<CR>",
        desc = 'Select connection file',
      },
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
          funcs.create_tmux_pane('ipython --profile terminal', 30)
        end,
        desc = 'IPython Terminal',
      },
      {
        '<leader>ttJ',
        function()
          funcs.create_tmux_pane('source venv/bin/activate && jupyter console --kernel=$(basename $VIRTUAL_ENV)', 30)
        end,
        desc = 'Jupyter Console (basename)',
      },
      { '<leader>ttb', funcs.start_browser_sync, desc = 'Start browser-sync on ~/html', silent = true },
      { '<leader>tti', funcs.open_jupyter_console, desc = 'Jupyter Console' },
      { '<leader>ttj', ':split term://julia<CR>', desc = 'Julia Terminal' },
      { '<leader>ttp', ':split term://python<CR>', desc = 'Python Terminal' },
      { '<leader>ttr', ':split term://R<CR>', desc = 'R Terminal' },
      { '<leader>ttt', '<Cmd>lua require("FTerm").toggle()<CR>', desc = 'Toggle Terminal (Ctrl-`)' },
      { '<leader>ttv', funcs.run_df_explorer, desc = 'DataFrame Explorer' },

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
      { '<leader>zst', funcs.toggle_light_dark_theme, desc = 'Switch theme' },
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
        --
        -- CodeCompanion keybindings
        { '<leader>co', '<cmd>CodeCompanionActions<cr>', desc = 'CodeCompanion Actions', icon = '' }, -- Actions icon
        { '<leader>ct', '<cmd>CodeCompanionToggle<cr>', desc = 'CodeCompanion Toggle', icon = '' }, -- Toggle icon
        { '<leader>cc', '<cmd>CodeCompanion<cr>', desc = 'CodeCompanion', icon = '' }, -- CodeCompanion icon
        { '<leader>ca', '<cmd>CodeCompanionAdd<cr>', desc = 'CodeCompanion Add', icon = '' }, -- Add icon
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
