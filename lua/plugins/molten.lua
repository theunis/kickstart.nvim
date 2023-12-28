return {
  'benlubas/molten-nvim',
  version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
  build = ':UpdateRemotePlugins',
  lazy=false,
  init = function()
    -- these are examples, not defaults. Please see the readme
    vim.g.molten_image_provider = 'image.nvim'
    vim.g.molten_output_win_max_height = 20
    vim.g.molten_auto_open_output = false

    -- vim.keymap.set('n', '<localleader>rd', ':MoltenDelete<CR>', { silent = true, noremap = true, desc = 'molten delete cell' })
    -- vim.keymap.set('n', '<localleader>oh', ':MoltenHideOutput<CR>', { silent = true, noremap = true, desc = 'hide output' })
    -- vim.keymap.set('n', '<localleader>os', ':noautocmd MoltenEnterOutput<CR>', { silent = true, noremap = true, desc = 'show/enter output' })
  end,
}
