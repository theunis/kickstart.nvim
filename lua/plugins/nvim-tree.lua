return {
  'nvim-tree/nvim-tree.lua',
  opts = {
    disable_netrw = true,
    git = {
      enable = true,
      ignore = false,
      timeout = 500,
    },
    diagnostics = {
      enable = true,
    },
  },
  cmd = 'NvimTreeToggle',
}
