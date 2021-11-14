local vim = vim
local g = vim.g
local opt = vim.opt
local cmd = vim.cmd

-- set leader to space
g.mapleader = " "
-- turn off gopls for vim-go, let native lsp handle it
g.go_gopls_enabled = 0
-- Enable per-command history.
-- CTRL-N and CTRL-P will be automatically bound to next-history and
-- previous-history instead of down and up. If you don't like the change,
-- explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
g.fzf_history_dir = '~/.local/share/fzf-history'


opt.mouse = 'c' -- turn off mouse
opt.clipboard='unnamedplus' -- always default to system clipboard
opt.autoread=true -- autoread files when they change
opt.number = true -- line numbers
opt.wrap = false -- turn off word wrap
opt.background='dark' -- highlight Normal ctermbg=None

-- tabs to 4 spaces
opt.expandtab = true
opt.shiftwidth=4
opt.softtabstop=4

-- set bash like file autocompletion
opt.wildmode='longest,list,full'
opt.wildmenu=true

cmd('filetype plugin indent on')
