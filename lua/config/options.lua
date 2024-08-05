-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
local opt = vim.opt

-- Tab / Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false

-- Appearance
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.colorcolumn = '80'
opt.cmdheight = 1
opt.scrolloff = 10
opt.completeopt = 'menuone,noinsert,noselect'

-- Behaviour
opt.hidden = true
opt.errorbells = false
opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.expand '~/.vim/undodir'
opt.undofile = true
opt.backspace = 'indent,eol,start'
opt.splitright = true
opt.splitbelow = true
opt.autochdir = false
opt.iskeyword:append '-'
opt.mouse:append 'a'
opt.clipboard:append 'unnamedplus'
opt.modifiable = true
opt.encoding = 'UTF-8'
opt.breakindent = true
opt.signcolumn = 'yes'

-- Conceal level
opt.conceallevel = 1

-- Decrease update time
opt.updatetime = 250
opt.timeoutlen = 300

-- Molten
vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim/bin/python3'

vim.o.tags = vim.o.tags .. ',.tags_columns'

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
