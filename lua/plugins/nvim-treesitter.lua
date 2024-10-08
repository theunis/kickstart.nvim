local config = function()
  require('nvim-treesitter.configs').setup {

    ensure_installed = {
      'bash',
      'c',
      'html',
      'json',
      'jsonc',
      'lua',
      'luadoc',
      'luap',
      'markdown',
      'markdown_inline',
      'query',
      'regex',
      'vim',
      'vimdoc',
      'python',
      'yaml',
      'r',
    },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    -- indent = { enable = true },
    indent = {
      enable = true,
      disable = { 'dart' },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
      },
    },
    include_surrounding_whitespace = true,
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = { query = '@parameter.outer', desc = 'Select outer part of argument' },
          ['ia'] = { query = '@parameter.inner', desc = 'Select inner part of argument' },
          ['af'] = { query = '@function.outer', desc = 'Select outer part of a function region' },
          ['if'] = { query = '@function.inner', desc = 'Select inner part of a function region' },
          ['ac'] = { query = '@class.outer', desc = 'Select outer part of a class region' },
          ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.inner',
          -- ['<C-n>'] = '@class.outer',
          [']a'] = '@attribute.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.inner',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.inner',
          -- ['<C-p>'] = '@class.outer',
          ['[a'] = '@attribute.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.inner',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end

return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  config = config,
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    {
      'chrisgrieser/nvim-various-textobjs',
      event = 'UIEnter',
      opts = { useDefaultKeymaps = true },
    },
    'nvim-treesitter/nvim-treesitter-context',
  },
  build = ':TSUpdate',
}
