return {
  "olimorris/codecompanion.nvim",
  cmd = "CodeCompanion",
  opts = {
    adapters = {
      ollama = function()
        return require("codecompanion.adapters").use("ollama", {
          schema = {
            model = {
              default = "llama3.1:latest",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "ollama",
      },
      inline = {
        adapter = "ollama",
      },
      agent = {
        adapter = "ollama",
      },
    },
  },
  -- dependencies = {
  --   'nvim-lua/plenary.nvim',
  --   'nvim-treesitter/nvim-treesitter',
  -- },
  config = true,
  init = function()
    vim.cmd([[cab cc CodeCompanion]])
  end,
}
