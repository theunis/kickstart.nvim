-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }
    -- Dart / Flutter
    dap.adapters.dart = {
      type = 'executable',
      command = 'dart',
      args = { 'debug_adapter' },
    }
    dap.adapters.flutter = {
      type = 'executable',
      command = 'flutter',
      args = { 'debug_adapter' },
    }
    dap.configurations.dart = {
      {
        type = 'dart',
        request = 'launch',
        name = 'Launch dart',
        dartSdkPath = '/Users/theunvanvliet/Documents/Development/Flutter.nosync/flutter/bin/flutter/bin/cache/dart-sdk/', -- ensure this is correct
        flutterSdkPath = '/Users/theunvanvliet/Documents/Development/Flutter.nosync/flutter/bin/flutter', -- ensure this is correct
        program = '${workspaceFolder}/lib/main.dart', -- ensure this is correct
        cwd = '${workspaceFolder}',
      },
      {
        type = 'flutter',
        request = 'launch',
        name = 'Launch flutter',
        dartSdkPath = '/Users/theunvanvliet/Documents/Development/Flutter.nosync/flutter/bin/flutter/bin/cache/dart-sdk/', -- ensure this is correct
        flutterSdkPath = '/Users/theunvanvliet/Documents/Development/Flutter.nosync/flutter/bin/flutter', -- ensure this is correct
        program = '${workspaceFolder}/lib/main.dart', -- ensure this is correct
        cwd = '${workspaceFolder}',
      },
    }
    -- Basic debugging keymaps, feel free to change to your liking!
    -- vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    -- vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    -- vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    -- vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    -- vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    -- vim.keymap.set('n', '<leader>B', function()
    --   dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    -- end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      -- icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      -- controls = {
      --   icons = {
      --     pause = '⏸',
      --     play = '▶',
      --     step_into = '⏎',
      --     step_over = '⏭',
      --     step_out = '⏮',
      --     step_back = 'b',
      --     run_last = '▶▶',
      --     terminate = '⏹',
      --     disconnect = '⏏',
      --   },
      -- },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    -- vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- DAP key mappings with descriptions for which-key
    -- local dap_mappings = {
    --   ['<leader>d'] = {
    --     name = 'Debug',
    --     c = { "<Cmd>lua require'dap'.continue()<CR>", 'Continue', mode = 'n' },
    --     o = { "<Cmd>lua require'dap'.step_over()<CR>", 'Step Over', mode = 'n' },
    --     i = { "<Cmd>lua require'dap'.step_into()<CR>", 'Step Into', mode = 'n' },
    --     u = { "<Cmd>lua require'dap'.step_out()<CR>", 'Step Out', mode = 'n' },
    --     b = { "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", 'Toggle Breakpoint', mode = 'n' },
    --     B = { "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", 'Set Conditional Breakpoint', mode = 'n' },
    --     l = { "<Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", 'Set Log Point', mode = 'n' },
    --     r = { "<Cmd>lua require'dap'.repl.open()<CR>", 'Open REPL', mode = 'n' },
    --     a = { "<Cmd>lua require'dap'.run_last()<CR>", 'Run Last', mode = 'n' },
    --   },
    --   ['<leader>du'] = {
    --     name = 'DAP UI',
    --     t = { "<Cmd>lua require'dapui'.toggle()<CR>", 'Toggle UI', mode = 'n' },
    --     e = { "<Cmd>lua require'dapui'.eval()<CR>", 'Evaluate', mode = 'n' },
    --     E = { "<Cmd>lua require'dapui'.eval(vim.fn.input('Eval expression: '))<CR>", 'Evaluate Expression', mode = 'n' },
    --     h = { "<Cmd>lua require'dapui'.hover()<CR>", 'Hover Variables', mode = 'n' },
    --     s = { "<Cmd>lua require'dapui'.scopes()<CR>", 'Scopes', mode = 'n' },
    --     f = { "<Cmd>lua require'dapui'.float_element()<CR>", 'Float Element', mode = 'n' },
    --   },
    -- }

    -- Register the mappings with which-key
    -- require('which-key').register(dap_mappings)
  end,
}
