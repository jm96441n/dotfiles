" turn off mouse mode
set mouse=c

" tabs to 2 spaces
set expandtab
set shiftwidth=2
set softtabstop=2
filetype plugin indent on

" live reload files if it changes on disk
set autoread

" line numbers
set number

" use control s to save and exit insert mode
map <C-s> <esc>:w<CR>
imap <C-s> <esc>:w<CR>

" additional escapes
imap jk <esc>
imap kj <esc>

" no arrow keys
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>

inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Plugins!
call plug#begin('~/.vim/plugged')

Plug 'w0rp/ale'
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-ruby/vim-ruby'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mechatroner/rainbow_csv'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-rails'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'morhetz/gruvbox'
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'

call plug#end()

" Change keymap for nerdtree
map <C-n> :NERDTreeToggle<CR> 

" Theme
" colorscheme dracula
colorscheme gruvbox
set background=dark

" set column
set cc=120
highlight ColorColumn guibg=red

