set nocompatible

if has('win32') || has('win64')
    call plug#begin('~/vimfiles/plugged')
else
    call plug#begin('~/.vim/plugged')
endif

Plug 'christoomey/vim-tmux-navigator'
Plug 'edkolev/tmuxline.vim'
Plug 'embear/vim-localvimrc'
Plug 'godlygeek/csapprox'
Plug 'godlygeek/tabular'
Plug 'hdima/python-syntax'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'
Plug 'vim-scripts/Colour-Sampler-Pack'
Plug 'vim-scripts/camelcasemotion'
Plug 'vimperator/vimperator.vim'

" colorschemes
Plug 'altercation/vim-colors-solarized'
Plug 'chriskempson/base16-vim'
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'tomasr/molokai'
Plug 'vim-airline/vim-airline-themes'
Plug 'w0ng/vim-hybrid'

call plug#end()

filetype plugin indent on
syntax enable

set number
set hidden
set virtualedit=block
set wildmenu
set wildmode=longest:full,full
set nowrap
set nostartofline
set ruler
set history=1000
set showcmd
set incsearch
set hlsearch
set mouse=a
set mousemodel=popup
set backspace=indent,eol,start
set formatprg=par
set visualbell t_vb=

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
let g:airline_extensions = ['tabline']
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#show_tab_type = 0
let g:tmuxline_powerline_separators = 0

if has('win32') || has('win64')
    colorscheme default
    set directory^=~/vimfiles/swap//
    set undodir=~/vimfiles/undo
else
    colorscheme asu1dark
    set directory^=~/.vim/swap//
    set undodir=~/.vim/undo
endif

let mapleader = "\<space>"
nnoremap <silent> <leader>c :setlocal cursorline!<CR>
nnoremap <silent> <leader>n :nohlsearch<CR>

nmap Y y$
nmap <Left>  :bp<CR>
nmap <Right> :bn<CR>

" When editing a file, always jump to the last known cursor position.  Don't
" do it when the position is invalid or when inside an event handler (happens
" when dropping a file on gvim). Also don't do it when the mark is in the
" first line, that is the default position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

let c_space_errors = 1
let python_highlight_all = 1

autocmd BufRead,BufNewFile *.vx setfiletype verilog
autocmd FileType arduino,c,cpp,cs setlocal commentstring=//%s
autocmd FileType java setlocal noexpandtab
autocmd FileType python setlocal foldmethod=indent
