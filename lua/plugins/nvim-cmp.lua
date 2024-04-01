return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    local lspkind = require 'lspkind'
    luasnip.config.setup {}

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { completeopt = 'menu,menuone,noinsert' },

      mapping = cmp.mapping.preset.insert {
        ['<C-k>'] = cmp.mapping.select_prev_item(), -- previous suggestion
        ['<C-j>'] = cmp.mapping.select_next_item(), -- next suggestion
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(), -- show completion suggestions
        ['<C-e>'] = cmp.mapping.abort(), -- close completion window
        ['<C-y>'] = cmp.mapping.confirm { select = true },
        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),

        -- Select the previous choice in a choice node
        ['<C-p>'] = cmp.mapping(function()
          if luasnip.choice_active() then
            luasnip.change_choice(-1)
          end
        end, { 'i', 's' }),
        -- Select the next choice in a choice node
        ['<C-n>'] = cmp.mapping(function()
          if luasnip.choice_active() then
            luasnip.change_choice(1)
          end
        end, { 'i', 's' }),
      },

      -- sources for autocompletion
      sources = cmp.config.sources {
        { name = 'jupyter' },
        { name = 'otter' },
        { name = 'path' }, -- file system paths
        { name = 'nvim_lsp' }, -- lsp
        { name = 'nvim_lsp_signature_help' },
        { name = 'luasnip' }, -- snippets
        { name = 'buffer' }, -- text within current buffer
        { name = 'treesitter' },
        { name = 'tags' },
        { name = 'copilot' }, --, group_index = 2 },
      },
      -- configure lspkind for vs-code like icons
      formatting = {
        format = lspkind.cmp_format {
          ellipsis_char = '...',
          mode = 'symbol_text',
          maxwidth = 60,
          menu = {
            otter = '🦦',
            jupyter = '🪐',
            nvim_lsp = '',
            buffer = '﬘',
            luasnip = '',
            path = '',
            git = '',
            tags = '',
            cmdline = 'גּ',
            latex_symbols = '',
            Copilot = '',
          },
        },
      },
    }
    -- for custom snippets
    require('luasnip.loaders.from_lua').load { paths = '~/.config/nvim/lua/snippets/' }
    require('luasnip.loaders.from_vscode').load { paths = { '~/.config/nvim/snips' } }
    -- require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snips" } })
    luasnip.filetype_extend('quarto', { 'python' })
    -- luasnip.filetype_extend('quarto', { 'markdown' })
  end,
  dependencies = {
    'onsails/lspkind.nvim',
    {

      'L3MON4D3/LuaSnip',
      -- follow latest release.
      version = '2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = 'make install_jsregexp',
      dependencies = {
        -- `friendly-snippets` contains a variety of premade snippets.
        --    See the README about individual language/framework/plugin snippets:
        --    https://github.com/rafamadriz/friendly-snippets
        {
          'rafamadriz/friendly-snippets',
          config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
          end,
        },
      },
    },
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    -- Quarto / Otter
    'jmbuhr/otter.nvim',
    'quangnguyen30192/cmp-nvim-tags',
  },
}
