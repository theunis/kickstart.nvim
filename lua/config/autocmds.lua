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
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "quarto" },
  callback = function(args)
    if args.match == "python" or args.match == "quarto" then
      vim.opt_local.shiftwidth = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.expandtab = true
    end
  end,
})

-- -- Auto-reload config on save
-- vim.cmd [[
--   augroup AutoSourceVimrc
--     autocmd!
--     autocmd BufWritePost ~/.config/nvim/**/* source $MYVIMRC
--   augroup END
-- ]]

vim.api.nvim_create_autocmd("InsertEnter", { command = [[set norelativenumber]] })
vim.api.nvim_create_autocmd("InsertLeave", { command = [[set relativenumber]] })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == "ruff" then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = "LSP: Disable hover capability from Ruff",
})

-- Create the autocmd to open Aerial only for markdown and quarto files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto" },
  callback = function()
    vim.cmd("AerialOpen")
  end,
  group = vim.api.nvim_create_augroup("AerialMarkdownQuarto", { clear = true }),
})
