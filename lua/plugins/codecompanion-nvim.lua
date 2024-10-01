return {
  'olimorris/codecompanion.nvim',
  cmd = 'CodeCompanion',
  opts = {
    -- adapters = {
    --   ollama = function()
    --     return require('codecompanion.adapters').use('ollama', {
    --       schema = {
    --         model = {
    --           default = 'llama3.1:latest',
    --         },
    --       },
    --     })
    --   end,
    -- },
    strategies = {
      chat = {
        adapter = 'ollama',
      },
      inline = {
        adapter = 'ollama',
      },
      agent = {
        adapter = 'ollama',
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'hrsh7th/nvim-cmp', -- Optional: For using slash commands and variables in the chat buffer
    {
      'stevearc/dressing.nvim', -- Optional: Improves the default Neovim UI
      opts = {},
    },
    'nvim-telescope/telescope.nvim', -- Optional: For using slash commands
  },
  config = true,
  init = function()
    vim.cmd [[cab cc CodeCompanion]]
  end,
}
