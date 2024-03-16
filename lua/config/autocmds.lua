-- auto-format on save
-- local lsp_fmt_group = vim.api.nvim_create_augroup('LspFormattingGroup', {})
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   group = lsp_fmt_group,
--   callback = function()
--     local efm = vim.lsp.get_active_clients { name = 'efm' }
--
--     if vim.tbl_isempty(efm) then
--       return
--     end
--
--     vim.lsp.buf.format { name = 'efm', async = true }
--   end,
-- })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- -- Auto-reload config on save
-- vim.cmd [[
--   augroup AutoSourceVimrc
--     autocmd!
--     autocmd BufWritePost ~/.config/nvim/**/* source $MYVIMRC
--   augroup END
-- ]]
