return {
  -- NOTE: First, some plugins that don't require any configuration
  -- Git related plugins
  { 'tpope/vim-fugitive', lazy = false },
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  { 'numToStr/FTerm.nvim', lazy = false },
  'ryanoasis/vim-devicons',

  { 'folke/neoconf.nvim', cmd = 'Neoconf' },
  'folke/neodev.nvim',
  { 'github/copilot.vim', lazy = false },
}
