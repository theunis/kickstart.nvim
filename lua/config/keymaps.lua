-- [[ Basic Keymaps ]]
local keymap = vim.keymap

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- NERDTree
-- keymap.set('n', '<leader>n', ":NERDTreeFocus<CR>", { desc = 'Focus on file tree' })
-- keymap.set('n', '<C-n>', ":NERDTree<CR>")
-- keymap.set('n', '<C-t>', ":NERDTreeToggle<CR>")
-- keymap.set('n', '<C-f>', ":NERDTreeFind<CR>")

-- Molten
keymap.set("n", "<localleader>R", ":MoltenEvaluateOperator<CR>",
	{ silent = true, noremap = true, desc = "run operator selection" })
keymap.set("n", "<localleader>rl", ":MoltenEvaluateLine<CR>",
	{ silent = true, noremap = true, desc = "evaluate line" })
keymap.set("n", "<localleader>rc", ":MoltenReevaluateCell<CR>",
	{ silent = true, noremap = true, desc = "re-evaluate cell" })
keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv",
	{ silent = true, noremap = true, desc = "evaluate visual selection" })

-- NvimTree
keymap.set('n', '<leader>n', ":NvimTreeFocus<CR>", { desc = 'Focus on file tree', silent = true })
keymap.set('n', '<C-n>', ":NvimTreeToggle<CR>", { silent = true })
keymap.set('n', '<C-f>', ":NvimTreeFindFile<CR>", { silent = true })
