" turn off mouse mode
set mouse=c

" tabs to 2 spaces
set expandtab
set shiftwidth=2
set softtabstop=2
filetype plugin indent on

" set tabs to 8 spaces in go files
autocmd FileType go setlocal shiftwidth=8 softtabstop=8 expandtab

" live reload files if it changes on disk
set autoread

" line numbers
" set number

set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" turn off word wrap
set nowrap

" set bash like file autocompletion
set wildmode=longest,list,full
set wildmenu

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

" Multi language linter
Plug 'w0rp/ale'
" All the syntax highlighting
Plug 'sheerun/vim-polyglot'
" All the autocompletion
Plug 'https://github.com/Valloric/YouCompleteMe'
" Keybindings for navigating between vim and tmux
Plug 'christoomey/vim-tmux-navigator'
" Ruby configs
Plug 'vim-ruby/vim-ruby'
" Tabline status
Plug 'vim-airline/vim-airline'
" Themes for vim-airline
Plug 'vim-airline/vim-airline-themes'
" Colorful CSV highlighting
Plug 'mechatroner/rainbow_csv'
" Useful VIM defaults
Plug 'tpope/vim-sensible'
" Easy navigation of rails project
Plug 'tpope/vim-rails'
" FZF for fuzzy file searching
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
" Dracula theme
Plug 'dracula/vim', { 'as': 'dracula' }
" Gruvbox theme
Plug 'morhetz/gruvbox'
" Easily create wrapping tags
Plug 'tpope/vim-surround'
" Shows git diff in gutter
Plug 'airblade/vim-gitgutter'
" Create text objects -- dependency for vim-textobj-ruby
Plug 'kana/vim-textobj-user'
" Quickly edit text objects within ruby
Plug 'rhysd/vim-textobj-ruby'
" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

call plug#end()

" fzf file fuzzy search that respects .gitignore
" If in git directory, show only files that are committed, staged, or unstaged
" else use regular :Files
nnoremap <expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles --exclude-standard --others --cached')."\<cr>"

" Theme
" colorscheme dracula
colorscheme gruvbox
" highlight Normal ctermbg=None
set background=dark

" set column
set cc=120
highlight ColorColumn guibg=red
