return {
  'olimorris/codecompanion.nvim',
  lazy = false,
  opts = {
    adapters = {
      ollama = function()
        return require('codecompanion.adapters').use('ollama', {
          schema = {
            model = {
              default = 'llama3.1:latest',
            },
          },
        })
      end,
    },
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
    'nvim-telescope/telescope.nvim', -- Optional
    {
      'stevearc/dressing.nvim', -- Optional: Improves the default Neovim UI
      opts = {},
    },
  },
  config = true,
  init = function()
    vim.cmd [[cab cc CodeCompanion]]
  end,
}
