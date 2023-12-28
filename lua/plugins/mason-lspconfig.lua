local opts = {
  ensure_installed = {
    'efm',
    'pyright',
    'lua_ls',
  },

  automatic_installation = true,
}

return {
  'williamboman/mason-lspconfig.nvim',
  opts = opts,
  event = 'BufReadPre',
  dependencies = 'williamboman/mason.nvim',
}
