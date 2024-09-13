return {
  'akinsho/flutter-tools.nvim',
  ft = 'dart',
  -- dependencies = {
  -- 	'nvim-lua/plenary.nvim',
  -- 	'stevearc/dressing.nvim', -- optional for vim.ui.select
  -- },
  opts = {
    decorations = {
      statusline = {
        app_version = true,
        device = true,
      },
    },
    debugger = {
      -- make these two params true to enable debug mode
      enabled = true,
      run_via_dap = true,
      register_configurations = function(_)
        require('dap').adapters.dart = {
          type = 'executable',
          command = vim.fn.stdpath 'data' .. '/mason/bin/dart-debug-adapter',
          args = { 'flutter' },
        }

        require('dap').configurations.dart = {
          {
            type = 'dart',
            request = 'launch',
            name = 'Launch flutter',
            dartSdkPath = '/Users/theunvanvliet/Documents/Development/Flutter.nosync/flutter/bin/flutter/bin/cache/dart-sdk/',
            flutterSdkPath = '/Users/theunvanvliet/Documents/Development/Flutter.nosync/flutter/bin/flutter',
            program = '${workspaceFolder}/lib/main.dart',
            cwd = '${workspaceFolder}',
          },
        }
        -- uncomment below line if you've launch.json file already in your vscode setup
        -- require("dap.ext.vscode").load_launchjs()
      end,
    },
    dev_log = {
      -- toggle it when you run without DAP
      enabled = false,
      open_cmd = 'tabedit',
    },
  },
}
