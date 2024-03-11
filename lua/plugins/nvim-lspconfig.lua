local on_attach = require('util.lsp').on_attach
local diagnostic_signs = require('util.lsp').diagnostic_signs

local config = function()
  require('neoconf').setup {}
  local cmp_nvim_lsp = require 'cmp_nvim_lsp'
  local lspconfig = require 'lspconfig'

  for type, icon in pairs(diagnostic_signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())

  -- local capabilities = cmp_nvim_lsp.default_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  -- lua
  lspconfig.lua_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = { -- custom settings for lua
      Lua = {
        -- make the language server recognize "vim" global
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          -- make language server aware of runtime files
          library = {
            [vim.fn.expand '$VIMRUNTIME/lua'] = true,
            [vim.fn.stdpath 'config' .. '/lua'] = true,
          },
        },
      },
    },
  }

  -- python
  lspconfig.pyright.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      pyright = {
        disableOrganizeImports = false,
        analysis = {
          useLibraryCodeForTypes = true,
          autoSearchPaths = true,
          diagnosticMode = 'workspace',
          autoImportCompletions = true,
        },
      },
    },
  }

  -- dart
  lspconfig.dartls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }

  local luacheck = require 'efmls-configs.linters.luacheck'
  local stylua = require 'efmls-configs.formatters.stylua'
  local flake8 = require 'efmls-configs.linters.flake8'
  local black = require 'efmls-configs.formatters.black'
  local dartanalyzer = require 'linters.dart_analyze'
  local dartfmt = require 'efmls-configs.formatters.dartfmt'
  -- configure efm server
  lspconfig.efm.setup {
    filetypes = {
      'lua',
      'python',
      'dart',
    },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
      hover = true,
      documentSymbol = true,
      codeAction = true,
      completion = true,
    },
    settings = {
      languages = {
        lua = { luacheck, stylua },
        python = { flake8, black },
        dart = { dartanalyzer, dartfmt },
      },
    },
  }
end

return {
  'neovim/nvim-lspconfig',
  config = config,
  lazy = false,
  dependencies = {
    'windwp/nvim-autopairs',
    'williamboman/mason.nvim',
    'creativenull/efmls-configs-nvim',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    { 'j-hui/fidget.nvim', opts = {} },
  },
}
