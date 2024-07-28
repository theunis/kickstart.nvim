local M = {}

M.on_attach = function(client, bufnr)
  local wk = require 'which-key'
  local opts = { noremap = true, silent = true, buffer = bufnr }

  client.server_capabilities.document_formatting = true

  local lsp_mappings = {
    ['<leader>'] = {},
  }

  if client.name == 'pyright' then
    lsp_mappings['<leader>']['t'] = {
      name = 'Tools',
      i = { '<Cmd>PyrightOrganizeImports<CR>', 'Organize Imports' },
    }
  end

  -- Register the mappings with which-key
  wk.register(lsp_mappings, opts)
end

M.diagnostic_signs = { Error = ' ', Warn = ' ', Hint = 'ﴞ ', Info = '' }

return M
