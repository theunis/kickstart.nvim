return {
  'jackMort/ChatGPT.nvim',
  event = 'VeryLazy',
  config = function()
    require('chatgpt').setup {
      api_key_cmd = 'op read op://private/OpenAI/credential --no-newline',
      openai_params = {
        model = 'gpt-3.5-turbo-0125',
        max_tokens = 3000,
      },
      openai_edit_params = {
        model = 'gpt-3.5-turbo-0125',
        max_tokens = 3000,
      },
    }
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
  },
}
