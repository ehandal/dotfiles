set nocompatible

if has('win32') || has('win64')
    call plug#begin('~/vimfiles/plugged')
else
    call plug#begin('~/.vim/plugged')
endif

Plug 'christoomey/vim-tmux-navigator'
Plug 'edkolev/tmuxline.vim'
Plug 'embear/vim-localvimrc'
" Plug 'godlygeek/csapprox'
Plug 'godlygeek/tabular'
Plug 'hdima/python-syntax'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'

" colorschemes
Plug 'altercation/vim-colors-solarized'
Plug 'chriskempson/base16-vim'
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'tomasr/molokai'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/Colour-Sampler-Pack'
Plug 'w0ng/vim-hybrid'


call plug#end()

filetype plugin indent on
syntax enable

set hidden
set virtualedit=block
set wildmenu
set wildmode=longest:full,full
set nowrap
set nostartofline
set ruler
set history=10000
set showcmd
set mouse=a
set mousemodel=popup
set backspace=indent,eol,start
set formatprg=par
set visualbell t_vb=

set hlsearch
set ignorecase
set incsearch
set smartcase

set tabstop=4
set shiftwidth=4
set expandtab
set smarttab

set nofoldenable
set foldmethod=syntax
set foldopen-=block

set undofile
set nobackup

set laststatus=2
set ttimeoutlen=10
set noshowmode
let g:airline_extensions = ['branch', 'tabline']
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#show_tab_type = 0

let g:tmuxline_powerline_separators = 0
let g:tmuxline_preset = {
      \'a'       : '#S',
      \'win'     : ['#I', '#W'],
      \'cwin'    : ['#I', '#W'],
      \'z'       : '#H',
      \'options' : {'status-justify' : 'left'}}

if has('win32') || has('win64')
    colorscheme default
    set directory^=~/vimfiles/swap//
    set undodir=~/vimfiles/undo
else
    set background=dark
    colorscheme base16-tomorrow-night
    set directory^=~/.vim/swap//
    set undodir=~/.vim/undo
endif

let mapleader = "\<space>"
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>n :nohlsearch<CR>
nnoremap <silent> <leader>t :Tags<CR>
nnoremap <silent> <leader>w :update<CR>

nmap Y y$
nmap <Left>  :bp<CR>
nmap <Right> :bn<CR>

" :help last-position-jump
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

let c_space_errors = 1
let python_highlight_all = 1

autocmd BufRead,BufNewFile *.vx setfiletype verilog
autocmd BufRead,BufNewFile gitconfig setfiletype gitconfig
autocmd FileType arduino,c,cpp,cs,cuda setlocal commentstring=//%s
autocmd FileType c,cpp,python setlocal foldmethod=indent
autocmd FileType gitconfig,java setlocal noexpandtab
