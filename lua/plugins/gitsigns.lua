return {
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      local wk = require 'which-key'
      local gs = package.loaded.gitsigns
      local mappings = {
        {
          '<leader>tg',
          group = 'Git',
        },
        { '<leader>tgp', gs.preview_hunk, 'Preview Hunk', buffer = bufnr },
        {
          '<leader>[c',
          name = 'Previous',
          function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(gs.prev_hunk)
            return '<Ignore>'
          end,
          'Git Hunk',
          expr = true,
          buffer = bufnr,
        },
        {
          '<leader>]c',
          name = 'Next',
          function()
            if vim.wo.diff then
              return 'c'
            end
            vim.schedule(gs.next_hunk)
            return '<Ignore>'
          end,
          'Git Hunk',
          expr = true,
          buffer = bufnr,
        },
      }

      -- Register the mappings with which-key
      wk.register(mappings)
    end,
  },
}
