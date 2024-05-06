return {
  -- NOTE: First, some plugins that don't require any configuration
  -- Git related plugins
  { "tpope/vim-fugitive", lazy = false },
  "tpope/vim-rhubarb",

  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  { "numToStr/FTerm.nvim", lazy = false },
  "ryanoasis/vim-devicons",

  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "folke/neodev.nvim",
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
    opts = {
      event = { "InsertEnter", "LspAttach" },
      fix_pairs = true,
    },
  },
  {
    "HampusHauffman/block.nvim",
    lazy = false,
    config = function()
      require("block").setup({})
    end,
  },
  {
    "unblevable/quick-scope",
    lazy = false,
  },
}
