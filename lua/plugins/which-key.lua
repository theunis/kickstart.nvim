return {
  "folke/which-key.nvim",
  lazy = false,
  opts = {},

  init = function()
    local function toggle_light_dark_theme()
      if vim.o.background == "light" then
        vim.o.background = "dark"
        vim.cmd([[Catppuccin mocha]])
      else
        vim.o.background = "light"
        vim.cmd([[Catppuccin latte]])
      end
    end

    local function start_browser_sync()
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

    local function send_dataframe_to_duckdb()
      -- Get the word under the cursor, assumed to be the DataFrame variable name
      local dataframe_name = vim.fn.expand("<cword>")
      local db_location = vim.fn.getcwd() .. "/default.duckdb"

      -- Construct the to_duckdb magic command with the DataFrame name
      local command = "%to_duckdb " .. dataframe_name .. " " .. dataframe_name .. ' "' .. db_location .. '"\n'

      -- Send the command to IPython via vim-slime
      vim.fn["slime#send"](command)
    end

    local function send_dataframe_to_feather()
      -- Get the word under the cursor, assumed to be the DataFrame variable name
      local dataframe_name = vim.fn.expand("<cword>")

      -- Construct the to_feather magic command with the DataFrame name
      local command = "%to_feather " .. dataframe_name .. " " .. dataframe_name .. ".feather\n"

      -- Send the command to IPython via vim-slime
      vim.fn["slime#send"](command)
    end

    local function execute_code_block_and_move()
      -- This is a placeholder for the command to execute the current block in vim-slime.
      -- You'll need to replace `<cmd>` with the actual command or sequence to execute the block.
      -- Send to terminal and scroll down:
      -- send_to_terminal_and_scroll_down()
      -- vim.cmd("QuartoSend")

      vim.api.nvim_exec("QuartoSend", false)

      -- Logic to move to the next code block after execution.
      -- This is highly simplified and needs to be replaced with actual logic to move to the next code block.
      -- For example, you might search for the next set of triple backticks in markdown.
      vim.cmd("normal ]]")

      -- Optionally, move the cursor down one line if needed.
      vim.cmd("normal! j")
    end

    local function create_qmd_scratch_file()
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

    local function quarto_conditional(command, otter_func)
      return function()
        if vim.bo.filetype == "quarto" or vim.bo.filetype == "qmd" then
          require("otter")[otter_func]()
        else
          vim.cmd(command)
        end
      end
    end

    local function create_tmux_pane(command)
      -- Create new vertical split and get the pane id
      local pane_id = vim.fn.system("tmux split-window -v -P -F '#{pane_id}' '" .. command .. "'")
      -- Use the pane id to set the vim-slime target pane
      vim.g.slime_default_config = { socket_name = "default", target_pane = pane_id }
    end

    -- General keybindings
    local mappings = {
      ["<S-CR>"] = { execute_code_block_and_move, "Execute code block and move to next" },
      -- ["<S-CR>"] = { "<Cmd>QuartoSend<CR>" },
      ["<leader>"] = {
        ["<CR>"] = { send_to_terminal_and_scroll_down, "Execute Code Chunk" },
        ["/"] = { "<Cmd>Telescope current_buffer_fuzzy_find<CR>", "Fuzzy Buffer" },
        ["?"] = { "<Cmd>Telescope help_tags<CR>", "Help Tags" },
        ["["] = {
          name = "Previous",
          d = { "<Cmd>lua vim.diagnostic.goto_prev()<CR>", "Diagnostic" },
          c = { "<Cmd>MoltenPrev<CR>", "Code chunk" },
        },
        ["]"] = {
          name = "Next",
          d = { "<Cmd>lua vim.diagnostic.goto_next()<CR>", "Diagnostic" },
          c = { "<Cmd>MoltenNext<CR>", "Code chunk" },
        },
        -- File & Project Management
        b = {
          name = "Buffer",
          b = { "<Cmd>Telescope buffers<CR>", "Switch Buffer" },
          k = { "<Cmd>bd<CR>", "Kill Buffer" },
          l = { "<Cmd>ls<CR>", "List Buffers" },
        },
        c = {
          name = "ChatGPT",
          c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
          e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
          g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
          t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
          k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
          d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
          a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
          o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
          s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
          f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
          x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
          r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
          l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
        },

        -- Debugging
        d = {
          name = "Debug",
          c = { "<Cmd>lua require'dap'.continue()<CR>", "Continue" },
          s = { "<Cmd>lua require'dap'.step_over()<CR>", "Step Over" },
          i = { "<Cmd>lua require'dap'.step_into()<CR>", "Step Into" },
          o = { "<Cmd>lua require'dap'.step_out()<CR>", "Step Out" },
          b = { "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", "Toggle Breakpoint" },
          B = {
            "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
            "Conditional Breakpoint",
          },
          l = { "<Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", "Log Point" },
          r = { "<Cmd>lua require'dap'.repl.open()<CR>", "Open REPL" },
          a = { "<Cmd>lua require'dap'.run_last()<CR>", "Run Last" },
          u = {
            name = "DAP UI",
            t = { "<Cmd>lua require'dapui'.toggle()<CR>", "Toggle UI" },
            e = { "<Cmd>lua require'dapui'.eval()<CR>", "Evaluate" },
            E = { "<Cmd>lua require'dapui'.eval(vim.fn.input('Eval expression: '))<CR>", "Evaluate Expression" },
            h = { "<Cmd>lua require'dapui'.hover()<CR>", "Hover Variables" },
            s = { "<Cmd>lua require'dapui'.scopes()<CR>", "Scopes" },
            f = { "<Cmd>lua require'dapui'.float_element()<CR>", "Float Element" },
          },
        },
        -- Slime Commands
        e = {
          name = "Execute",
          ["<CR>"] = { "<Plug>QuartoSendRange<CR>", "Send Region", mode = "v" },
        },
        f = {
          name = "File",
          t = { "<Cmd>NvimTreeToggle<CR>", "Toggle Tree" },
          f = { "<Cmd>NvimTreeFindFile<CR>", "Find File" },
          r = { "<Cmd>Telescope oldfiles<CR>", "Recent Files" },
        },
        g = {
          name = "Go",
          F = { "<Cmd>Lspsaga finder<CR>", "Finder" },
          d = { quarto_conditional("Lspsaga peek_definition", "ask_definition"), "Peek/Ask Definition" },
          D = { quarto_conditional("Lspsaga goto_definition", "ask_definition"), "Goto/Ask Definition" },
          h = { quarto_conditional("Lspsaga hover_doc", "ask_hover"), "Hover Doc/Ask Hover" },
        },
        -- LSP
        l = {
          name = "LSP",
          -- n = { '<Cmd>lua vim.diagnostic.goto_next()<CR>', 'Next Diagnostic' },
          -- p = { '<Cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous Diagnostic' },
          a = { quarto_conditional("Lspsaga code_action", "ask_code_action"), "Code Action" },
          c = { "<Cmd>Lspsaga show_cursor_diagnostics<CR>", "Cursor Diagnostics" },
          C = { "<Cmd>Lspsaga show_line_diagnostics<CR>", "Line Diagnostics" },
          d = { "<cmd>lua require('trouble').toggle('document_diagnostics')<cr>", "Document Diagnostics" },
          f = { "<Cmd>Format<CR>", "Format" },
          F = { "<Cmd>lua vim.diagnostic.open_float()<CR>", "Floating Diagnostic" },
          l = { "<cmd>lua require('trouble').toggle()<cr>", "Toggle Trouble" },
          L = { "<cmd>lua require('trouble').toggle('loclist')<cr>", "Location List" },
          n = { "<Cmd>Lspsaga diagnostic_jump_next<CR>", "Next Diagnostic" },
          o = { "<Cmd>lua vim.diagnostic.setloclist()<CR>", "Diagnostic List" },
          p = { "<Cmd>Lspsaga diagnostic_jump_prev<CR>", "Prev Diagnostic" },
          q = { "<cmd>lua require('trouble').toggle('quickfix')<cr>", "Quickfix" },
          r = { quarto_conditional("Lspsaga rename", "ask_rename"), "Rename" },
          w = { "<cmd>lua require('trouble').toggle('workspace_diagnostics')<cr>", "Workspace Diagnostics" },
        },
        -- Search & Quick Access
        s = {
          name = "Search",
          s = { "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>", "Workspace Symbols" },
          g = { "<Cmd>Telescope live_grep<CR>", "Grep Project" },
          f = { "<Cmd>Telescope find_files<CR>", "Find Files" },
          n = { "<Cmd>Telescope luasnip<CR>", "Snippets" },
          h = { "<Cmd>Telescope help_tags<CR>", "Help Tags" },
          k = { "<Cmd>Telescope keymaps<CR>", "Keymaps" },
          t = { "<Cmd>Telescope builtin<CR>", "Telescope" },
          w = { "<Cmd>Telescope grep_string<CR>", "Grep Word" },
          d = { "<Cmd>Telescope diagnostics<CR>", "Diagnostics" },
          [" "] = { "<Cmd>Telescope buffers<CR>", "Buffers" },
          ["."] = { "<Cmd>Telescope oldfiles<CR>", "Recent Files" },
          r = { "<Cmd>Telescope resume<CR>", "Resume" },
        },

        -- Quarto Commands
        q = {
          name = "Quarto",
          a = { ":QuartoActivate<CR>", "Activate" },
          p = { ":lua require'quarto'.quartoPreview()<CR>", "Preview" },
          q = { ":lua require'quarto'.quartoClosePreview()<CR>", "Close Preview" },
          h = { ":QuartoHelp ", "Help" },
          e = { ":lua require'otter'.export()<CR>", "Export" },
          E = { ":lua require'otter'.export(true)<CR>", "Export Overwrite" },
          r = {
            name = "Run",
            r = { ":QuartoSendAbove<CR>", "Run to Cursor" },
            a = { ":QuartoSendAll<CR>", "Run All" },
            b = { ":QuartoSendBelow<CR>", "Run below" },
            l = { ":QuartoSendLine<CR>", "Run line" },
          },
          s = { create_qmd_scratch_file, "Create .qmd scratch file" },
        },

        o = {
          name = "Code Chunk",
          a = { "o# %%<cr>", "New code chunk below" },
          A = { "O# %%<cr>", "New code chunk above" },
          b = { "o```{bash}<cr>```<esc>O", "Bash code chunk" },
          r = { "o```{r}<cr>```<esc>O", "R code chunk" },
          p = { "o```{python}<cr>```<esc>O", "Python code chunk" },
          o = { "k][jo```{python}<cr>```<esc>O", "Python code chunk below" },
          O = { "j[]kko```{python}<cr>```<esc>O", "Python code chunk above" },
          ["-"] = { "o```<cr><cr>```{python}<esc>kkk", "Split cell" },
        },

        -- Save
        r = {
          name = "Register",
          f = { send_dataframe_to_feather, "Save dataframe to Feather" },
          d = { send_dataframe_to_duckdb, "Save dataframe to DuckDB" },
          w = { ":vsplit term://vdsql default.duckdb<CR>", "Open DuckDB in Visidata" },
          v = { ":vsplit term://vd ./feather_data/<CR>", "Open Feather in Visidata" },
        },
        -- Tools
        t = {
          name = "Tools",
          u = { "<Cmd>UndotreeToggle<CR>", "Undo Tree" },
          a = { "<Cmd>AerialToggle!<CR>", "Aerial Outline" },
          t = {
            name = "Terminal",
            b = { start_browser_sync, "Start browser-sync on ~/html", silent = true },
            -- i = { ":split term://ipython --profile terminal<CR>", "IPython Terminal" },
            -- I = { ":silent !tmux split-window -v 'ipython --profile terminal'<CR>", "IPython Terminal" },
            -- i = { ":silent !tmux split-window -v 'jupyter console'<CR>", "Jupyter Console" },
            I = {
              function()
                create_tmux_pane("ipython --profile terminal")
              end,
              "IPython Terminal",
            },
            i = {
              function()
                create_tmux_pane("jupyter console")
              end,
              "Jupyter Console",
            },
            j = { ":split term://julia<CR>", "Julia Terminal" },
            p = { ":split term://python<CR>", "Python Terminal" },
            r = { ":split term://R<CR>", "R Terminal" },
            t = { '<Cmd>lua require("FTerm").toggle()<CR>', "Toggle Terminal (Ctrl-`)" },
            v = { ":!tmux split-window -t 1 -h '~/dotfiles/df_explorer.sh'<CR>", "DataFrame Explorer" },
          },
          c = {
            name = "Github Copilot",
            c = { '<Cmd>lua require"copilot".complete()<CR>', "Complete" },
            s = { '<Cmd>lua require"copilot".suggest()<CR>', "Suggest" },
            d = { "<Cmd>Copilot disable<CR>", "Disable" },
            e = { "<Cmd>Copilot enable<CR>", "Enable" },
          },
          m = {
            name = "Molten",
            i = { "<Cmd>MoltenInit<CR>", "Molten" },
            e = { "<Cmd>MoltenEvaluateLine<CR>", "Evaluate Line" },
            b = { "<Cmd>MoltenEvaluateOperator<CR>", "Run operator selection" },
            c = { "<Cmd>MoltenReevaluateCell<CR>", "Re-evaluate cell" },
            t = { "<Cmd>MoltenToggle<CR>", "Toggle Display" },
            d = { "<Cmd>MoltenDelete<CR>", "Delete Cell", noremap = true, silent = true },
            h = { "<Cmd>MoltenHideOutput<CR>", "Hide Output", noremap = true, silent = true },
            s = { "<Cmd>noautocmd MoltenEnterOutput<CR>", "Show/Enter Output", noremap = true, silent = true },
            r = { "<Cmd>MoltenOpenInBrowser<CR>", "Open in Browser" },
          },
          f = {
            name = "Flutter",
            c = { "<Cmd>Telescope flutter commands<CR>", "Flutter" },
            r = { "<Cmd>FlutterRun<CR>", "Run" },
            d = { "<Cmd>FlutterDevices<CR>", "Devices" },
            e = { "<Cmd>FlutterEmulators<CR>", "Emulators" },
            l = { "<Cmd>FlutterReload<CR>", "Hot Reload" },
            s = { "<Cmd>FlutterRestart<CR>", "Hot Restart" },
            t = { "<Cmd>FlutterTest<CR>", "Run Tests" },
          },
          g = {
            name = "Git",
            s = { "<Cmd>Telescope git_status<CR>", "Status" },
            c = { "<Cmd>Telescope git_commits<CR>", "Commits" },
            b = { "<Cmd>Telescope git_branches<CR>", "Branches" },
            f = { "<Cmd>Telescope git_files<CR>", "Files" },
            g = { "<Cmd>Git<CR>", "Git" },
          },
          s = {
            name = "Neotest",
            n = { ":lua require('neotest').run.run()<CR>", "Run Nearest Test" },
            f = { ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>", "Run Tests in File" },
            l = { ":lua require('neotest').run.run_last()<CR>", "Run Last Test" },
            a = { ":lua require('neotest').run.run({ suite = true })<CR>", "Run All Tests" },
            s = { ":lua require('neotest').summary.toggle()<CR>", "Toggle Summary" },
            o = { ":lua require('neotest').output.open()<CR>", "Open Output" },
            j = { ":lua require('neotest').diagnostic.goto_next()<CR>", "Next Failed Test" },
            k = { ":lua require('neotest').diagnostic.goto_prev()<CR>", "Previous Failed Test" },
            d = { ":lua require('neotest').run.run({strategy = 'dap'})", "Debug Test" },
          },
        },

        -- Workspace (Session) Management
        w = {
          name = "Workspace",
          s = { ":SessionSave<CR>", "Save Session" },
          l = { ":SessionRestore<CR>", "Load Session" },
        },

        -- Additional Functionalities
        z = {
          name = "Advanced",
          l = {
            name = "Learn",
            d = { "<Cmd>help<CR>", "Neovim Docs" },
            h = { "<Cmd>Telescope help_tags<CR>", "Help Tags" },
          },
          s = {
            name = "System & Env",
            e = { ":Telescope find_files cwd=~/.config/nvim/<CR>", "Edit Config" },
            v = { "<Cmd>source $MYVIMRC<CR>", "Reload Config" },
            t = { toggle_light_dark_theme, "Switch theme" },
            s = { require("luasnip.loaders").edit_snippet_files, "Open snippets" },
          },
        },
      },
      -- Additional keybind outside of leader key
      -- gR = { "<cmd>lua require('trouble').toggle('lsp_references')<cr>", 'LSP References' },
      ["["] = {
        name = "Previous",
        d = { "<Cmd>lua vim.diagnostic.goto_prev()<CR>", "Diagnostic" },
        c = { "<Cmd>MoltenPrev<CR>", "Code chunk" },
      },
      ["]"] = {
        name = "Next",
        d = { "<Cmd>lua vim.diagnostic.goto_next()<CR>", "Diagnostic" },
        c = { "<Cmd>MoltenNext<CR>", "Code chunk" },
      },
    }

    local is_code_chunk = function()
      local current, _ = require("otter.keeper").get_current_language_context()
      if current then
        return true
      else
        return false
      end
    end

    local insert_code_chunk = function(lang)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
      local keys
      if is_code_chunk() then
        keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
      else
        keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
      end
      keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
    end

    local insert_r_chunk = function()
      insert_code_chunk("r")
    end

    local insert_py_chunk = function()
      insert_code_chunk("python")
    end
    local wk = require("which-key")

    -- Special handling for Slime commands
    wk.register({
      ["<c-cr>"] = { ":SlimeSend<CR>", "Send Code Chunk" },
      ["<m-i>"] = { insert_r_chunk, "R code chunk" },
      ["<cm-i>"] = { insert_py_chunk, "Python code chunk" },
      ["<m-I>"] = { insert_py_chunk, "Python code chunk" },
    }, { mode = "n" }) -- Normal mode

    wk.register({
      ["<c-cr>"] = { "<esc>:SlimeSend<CR>i", "Send Code Chunk" },
      ["<m-i>"] = { insert_r_chunk, "R code chunk" },
      ["<cm-i>"] = { insert_py_chunk, "Python code chunk" },
      ["<m-I>"] = { insert_py_chunk, "Python code chunk" },
    }, { mode = "i" }) -- Insert mode

    wk.register({
      ["<c-cr>"] = { "<Plug>SlimeRegionSend<CR>", "Send Code Chunk" },
    }, { mode = "v" }) -- Visual mode

    -- Register the mappings with which-key
    wk.register(mappings)
  end,
}
