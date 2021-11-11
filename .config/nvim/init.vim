" turn off mouse mode
set mouse=c

" tabs to 2 spaces
set expandtab
set shiftwidth=2
set softtabstop=2
filetype plugin indent on
let g:mapleader=" "

" vim-go related remaps
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <leader>c  <Plug>(go-coverage-toggle)
" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" set textwidth only on markdown files
au BufRead,BufNewFile *.md setlocal textwidth=120

" set tabs to 4 spaces in python files
autocmd FileType py setlocal shiftwidth=4 softtabstop=4
" set tab width to 4 spaces in go files
autocmd FileType go setlocal shiftwidth=4 softtabstop=4

if executable('go')
  let g:go_jump_to_error = 0 " don't autojump to errors on :Go* commands
  let g:go_addtags_transform = 'snakecase'  " :GoAddTags on struct will transform as snake_case
  let g:go_fmt_command = 'goimports' " auto import on save
endif

" live reload files if it changes on disk
set autoread

" line numbers
 set number

" set number relativenumber

" augroup numbertoggle
"   autocmd!
"   autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
"   autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
" augroup END

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

" toggle relative line number
nmap <leader>rn :set rnu!<cr>

" set YouCompleteMe GoTo<something>
nnoremap <leader>jd :YcmCompleter GoTo<CR>

" toggle between files
nmap <leader>bb <c-^><cr>

" always copy to system clipboard
set clipboard+=unnamedplus

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Turn of ale lsp
let g:ale_disable_lsp = 1
let g:ale_python_flake8_options = '--max-line-length=120'
let g:ale_python_black_options = '-l 120'
let g:ale_fixers = {
\  '*': ['remove_trailing_lines', 'trim_whitespace'],
\  'python': ['black'],
\}
let g:ale_fix_on_save = 1

" Vim test plugins
nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-l> :TestLast<CR>
nmap <silent> t<C-g> :TestVisit<CR>

 function! CBIStrategy(cmd)
   let cmds = split(a:cmd)
   let filename = split(cmds[-1], "/")[-1]
   let pytest_matcher = split(filename, "::")[-1]
   let args = "-k  '" . pytest_matcher . "'"
   -tabnew
   call termopen('make unit args="' . args . '"')
   startinsert
 endfunction

let g:test#custom_strategies = {'cbi': function('CBIStrategy')}
let g:test#strategy = 'cbi'


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
" Go configs
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Tabline status
Plug 'vim-airline/vim-airline'
" Themes for vim-airline
Plug 'vim-airline/vim-airline-themes'
" Colorful CSV highlighting
Plug 'mechatroner/rainbow_csv'
" Useful VIM defaults
Plug 'tpope/vim-sensible'
" Surround things
Plug 'tpope/vim-surround'
" Easy navigation of rails project
Plug 'tpope/vim-rails'
" Useful git functionality
Plug 'tpope/vim-fugitive'
" FZF for fuzzy file searching
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'
" Plug '/usr/local/opt/fzf'
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
" Delve Debugging
Plug 'sebdah/vim-delve'
" Grammar checking for posts
Plug 'rhysd/vim-grammarous'
" Run tests!
Plug 'vim-test/vim-test'
" Indent highlighting
Plug 'Yggdroot/indentLine'

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

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'
