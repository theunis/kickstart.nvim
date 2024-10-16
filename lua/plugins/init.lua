return {
  -- NOTE: First, some plugins that don't require any configuration
  -- Git related plugins
  { "tpope/vim-fugitive", cmd = "Git" },
  "tpope/vim-rhubarb",

  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  "numToStr/FTerm.nvim",
  "ryanoasis/vim-devicons",

  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "folke/neodev.nvim",

  {
    "stevearc/dressing.nvim",
    opts = {},
  },
  -- {
  --   'zbirenbaum/copilot.lua',
  --   cmd = 'Copilot',
  --   event = 'InsertEnter',
  --   opts = {
  --     suggestion = { enabled = false },
  --     panel = { enabled = false },
  --   },
  -- },
  -- {
  --   'zbirenbaum/copilot-cmp',
  --   opts = {
  --     fix_pairs = true,
  --   },
  --   event = { 'InsertEnter', 'LspAttach' },
  -- },
  {
    "HampusHauffman/block.nvim",
    opts = {},
    cmd = { "Block", "BlockOn" },
  },
  {
    "unblevable/quick-scope",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
  },
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
  },
  {
    "tzachar/highlight-undo.nvim",
    opts = {},
    event = { "BufReadPre", "BufNewFile" },
  },
  { "Wansmer/sibling-swap.nvim", event = { "BufReadPre", "BufNewFile" } },
  {
    "stevearc/aerial.nvim",
    opts = {},
    cmd = "AerialOpen",
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
