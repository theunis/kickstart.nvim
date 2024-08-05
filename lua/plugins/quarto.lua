-- existing LazyVim config.
--
-- It configures all plugins necessary for quarto-nvim,
-- such as adding its code completion source to the
-- completion engine nvim-cmp.
-- Thus, instead of having to change your configuration entirely,
-- this takes your existings config and adds on top where necessary.

return {

  {
    'quarto-dev/quarto-nvim',
    keymap = {},
    dependencies = {

      -- this taps into vim.ui.select and vim.ui.input
      -- and in doing so currently breaks renaming in otter.nvim
      -- { 'stevearc/dressing.nvim', enabled = false },
      {
        'jmbuhr/otter.nvim',
        opts = {
          buffers = {
            set_filetype = true,
          },
        },
      },
      -- send code from python/r/qmd documets to a terminal or REPL
      -- like ipython, R, bash
      {
        'jpalardy/vim-slime',
        cmd = 'QuartoSend',
        init = function()
          -- Quarto Python chunk detection
          vim.b['quarto_is_' .. 'python' .. '_chunk'] = false
          _G.Quarto_is_in_python_chunk = function()
            require('otter.tools.functions').is_otter_language_context 'python'
          end

          vim.cmd [[
        let g:slime_dispatch_ipython_pause = 100
        function! SlimeOverride_EscapeText_quarto(text)
          call v:lua.Quarto_is_in_python_chunk()
          if exists('g:slime_python_ipython') && len(split(a:text, "\n")) > 1 && b:quarto_is_python_chunk
            " return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
            return a:text
          else
            return a:text
          endif
        endfunction
      ]]

          -- Slime and Neovim terminal configuration
          vim.g.slime_target = 'tmux'
          vim.g.slime_python_ipython = 1
          vim.g.slime_bracketed_paste = 1

          -- Terminal functions
          -- local function mark_terminal()
          --   vim.g.slime_last_channel = vim.b.terminal_job_id
          --   vim.api.nvim_out_write('Terminal marked: ' .. vim.g.slime_last_channel .. '\n')
          -- end
          --
          -- local function set_terminal()
          --   vim.b.slime_config = { jobid = vim.g.slime_last_channel }
          --   vim.api.nvim_out_write('Slime terminal set to: ' .. vim.g.slime_last_channel .. '\n')
          -- end

          -- -- Register keybindings with which-key
          -- require('which-key').register {
          --   ['<leader>tt'] = {
          --     name = 'Terminal',
          --     m = { mark_terminal, 'Mark Terminal' },
          --     s = { set_terminal, 'Set Terminal' },
          --   },
          -- }
        end,
      },
    },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { 'r', 'python', 'bash', 'html', 'lua' },
        diagnostics = {
          enabled = true,
          triggers = { 'BufWrite' },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = { 'slime' }, -- 'molten' or 'slime'
        ft_runners = { python = 'slime' }, -- filetype to runner, ie. `{ python = "molten" }`.
        -- Takes precedence over `default_method`
        never_run = { 'yaml' }, -- filetypes which are never sent to a code runner
      },
    },
    ft = 'quarto',
    -- keys = {
    --   { '<leader>qa', ':QuartoActivate<cr>', desc = 'quarto activate' },
    --   { '<leader>qp', ":lua require'quarto'.quartoPreview()<cr>", desc = 'quarto preview' },
    --   { '<leader>qq', ":lua require'quarto'.quartoClosePreview()<cr>", desc = 'quarto close' },
    --   { '<leader>qh', ':QuartoHelp ', desc = 'quarto help' },
    --   { '<leader>qe', ":lua require'otter'.export()<cr>", desc = 'quarto export' },
    --   { '<leader>qE', ":lua require'otter'.export(true)<cr>", desc = 'quarto export overwrite' },
    --   { '<leader>qrr', ':QuartoSendAbove<cr>', desc = 'quarto run to cursor' },
    --   { '<leader>qra', ':QuartoSendAll<cr>', desc = 'quarto run all' },
    --   { '<leader><cr>', ':SlimeSend<cr>', desc = 'send code chunk' },
    --   { '<c-cr>', ':SlimeSend<cr>', desc = 'send code chunk' },
    --   { '<c-cr>', '<esc>:SlimeSend<cr>i', mode = 'i', desc = 'send code chunk' },
    --   { '<c-cr>', '<Plug>SlimeRegionSend<cr>', mode = 'v', desc = 'send code chunk' },
    --   { '<cr>', '<Plug>SlimeRegionSend<cr>', mode = 'v', desc = 'send code chunk' },
    --   { '<leader>ctr', ':split term://R<cr>', desc = 'terminal: R' },
    --   { '<leader>cti', ':split term://ipython<cr>', desc = 'terminal: ipython' },
    --   { '<leader>ctp', ':split term://python<cr>', desc = 'terminal: python' },
    --   { '<leader>ctj', ':split term://julia<cr>', desc = 'terminal: julia' },
    -- },
  },
}
