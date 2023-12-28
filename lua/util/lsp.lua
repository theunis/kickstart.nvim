local M = {}

M.on_attach = function(client, bufnr)
  local wk = require 'which-key'
  local opts = { noremap = true, silent = true, buffer = bufnr }

  local lsp_mappings = {
    ['<leader>'] = {
      g = {
        name = 'Go',
        F = { '<Cmd>Lspsaga finder<CR>', 'Finder' },
        d = { '<Cmd>Lspsaga peek_definition<CR>', 'Peek Definition' },
        D = { '<Cmd>Lspsaga goto_definition<CR>', 'Goto Definition' },
        h = { '<Cmd>Lspsaga hover_doc<CR>', 'Hover Doc' },
      },
      r = {
        name = 'Refactor',
        n = { '<Cmd>Lspsaga rename<CR>', 'Rename' },
        a = { '<Cmd>Lspsaga code_action<CR>', 'Code Action' },
      },
      x = {
        name = 'Diagnostics',
        C = { '<Cmd>Lspsaga show_line_diagnostics<CR>', 'Line Diagnostics' },
        c = { '<Cmd>Lspsaga show_cursor_diagnostics<CR>', 'Cursor Diagnostics' },
        p = { '<Cmd>Lspsaga diagnostic_jump_prev<CR>', 'Prev Diagnostic' },
        n = { '<Cmd>Lspsaga diagnostic_jump_next<CR>', 'Next Diagnostic' },
      },
    },
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
