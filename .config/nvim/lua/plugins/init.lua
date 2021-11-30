local vim = vim
local cmd = vim.cmd
local call = vim.call
local fn = vim.fn

-- install vim-plug if it's not installed
local plugFile = io.open('~/.vim/autoload/plug.vim', 'w')
if plugFile~=nil then
    local http = require('socket.http')
    local body = http.request('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
    plugFile:write(body)
    local autoCommand = { auto_install_plugs = {{"VimEnter", "*", "PlugInstall --sync | source $MYVIMRC"}}}
    require ('autocmd').nvim_create_augroups(autoCommand)
    io.close(plugFile)
end


-- Plugins
local Plug = fn['plug#']

call('plug#begin', '~/.vim/plugged')
-- neovim lsp
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
-- autocomplete with nvmp-cmp
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
-- luasnip
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
-- Keybindings for navigating between vim and tmux
Plug 'christoomey/vim-tmux-navigator'
-- Tabline status
Plug 'vim-airline/vim-airline'
-- Themes for vim-airline
Plug 'vim-airline/vim-airline-themes'
-- Colorful CSV highlighting
Plug 'mechatroner/rainbow_csv'
-- FZF for fuzzy file searching
Plug ('junegunn/fzf', { ['do'] = fn['fzf#install'] })
-- Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
-- Gruvbox theme
Plug 'morhetz/gruvbox'
-- Shows git diff in gutter
Plug 'airblade/vim-gitgutter'
-- Markdown preview
Plug ('iamcco/markdown-preview.nvim', { ['do'] = 'cd app & yarn install' })
-- Delve Debugging
Plug 'sebdah/vim-delve'
-- Grammar checking for posts
Plug 'rhysd/vim-grammarous'
-- Indent highlighting
Plug 'Yggdroot/indentLine'
-- Run tests from vim
Plug 'vim-test/vim-test'
-- treesitter for better syntax highlighting
Plug('nvim-treesitter/nvim-treesitter', {['do'] = fn['TSUpdate']})
-- null-ls
Plug('jose-elias-alvarez/null-ls.nvim', {branch = "main"})
-- plenary
Plug('nvim-lua/plenary.nvim')

call('plug#end')

cmd('colorscheme gruvbox')
