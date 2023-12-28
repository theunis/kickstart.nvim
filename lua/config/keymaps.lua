-- [[ Basic Keymaps ]]
local keymap = vim.keymap
local mapkey = require('util.keymapper').mapkey

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Indenting
keymap.set('v', '<', '<gv')
keymap.set('v', '>', '>gv')

-- Pane and window navigation
keymap.set('n', '<C-h>', '<C-w>h') -- Navigate Left
keymap.set('n', '<C-j>', '<C-w>j') -- Navigate Down
keymap.set('n', '<C-k>', '<C-w>k') -- Navigate Up
keymap.set('n', '<C-l>', '<C-w>l') -- Navigate Right

keymap.set('n', '<C-`>', '<CMD>lua require("FTerm").toggle()<CR>')
keymap.set('t', '<C-`>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')

-- Diagnostic keymaps
-- keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- FLutter commands
-- keymap.set('n', '<leader>Fc', '<Cmd>Telescope flutter commands<CR>', { desc = '[F]lutter [C]ommands' })

-- You probably also want to set a keymap to toggle aerial
-- keymap.set('n', '<leader>t', '<cmd>AerialToggle!<CR>')

-- Molten
-- keymap.set('n', '<localleader>R', ':MoltenEvaluateOperator<CR>', { silent = true, noremap = true, desc = 'run operator selection' })
-- keymap.set('n', '<localleader>rl', ':MoltenEvaluateLine<CR>', { silent = true, noremap = true, desc = 'evaluate line' })
-- keymap.set('n', '<localleader>rc', ':MoltenReevaluateCell<CR>', { silent = true, noremap = true, desc = 're-evaluate cell' })
keymap.set('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, noremap = true, desc = 'Evaluate visual selection' })

-- NvimTree
-- keymap.set('n', '<leader>f', ':NvimTreeFocus<CR>', { desc = 'Focus on file tree', silent = true })
-- keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })
-- keymap.set('n', '<C-f>', ':NvimTreeFindFile<CR>', { silent = true })

-- Tools
-- keymap.set('n', '<leader>Tu', vim.cmd.UndotreeToggle, { desc = 'Toggle undo tree' })
-- keymap.set('n', '<leader>Tm', ':MoltenInit<CR>', { desc = 'Initialize Molten', silent = true })
-- keymap.set('n', '<leader>Tf', '<Cmd>Telescope flutter commands<CR>', { desc = 'Flutter commands', silent = true })
-- keymap.set('n', '<leader>Ta', '<Cmd>AerialToggle!<CR>', { desc = 'Toggle outline', silent = true })