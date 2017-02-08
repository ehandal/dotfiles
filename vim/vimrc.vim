set nocompatible

if has('win32') || has('win64')
    call plug#begin('~/vimfiles/plugged')
else
    call plug#begin('~/.vim/plugged')
endif

" github
Plug 'embear/vim-localvimrc'
"Plug 'ervandew/supertab'
Plug 'fholgado/minibufexpl.vim'
Plug 'godlygeek/csapprox'
Plug 'godlygeek/tabular'
Plug 'hdima/python-syntax'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'

" vim-scripts
Plug 'Colour-Sampler-Pack'
Plug 'camelcasemotion'

" non github repos
"Plug 'git://git.wincent.com/command-t.git'

call plug#end()

filetype plugin indent on
syntax on

set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set number
set hidden
set virtualedit=block
set wildmenu
set wildmode=longest:full,full
set guioptions-=T
set foldmethod=syntax
set foldopen-=block
set nobackup
set nowrap
set nostartofline
set ruler
set history=50
set showcmd
set incsearch
set hlsearch
set mouse=a
set mousemodel=popup
set backspace=indent,eol,start
set formatprg=par

" Turn off audible and visual bell
set visualbell t_vb=

if has('win32') || has('win64')
    colorscheme default
    set directory+=$TEMP
else
    colorscheme asu1dark
    set t_Co=256
endif

nnoremap <silent> <Leader>c :setlocal cursorline!<CR>

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-Tab is Next window
noremap <C-Tab> <C-W>w
inoremap <C-Tab> <C-O><C-W>w
cnoremap <C-Tab> <C-C><C-W>w
onoremap <C-Tab> <C-C><C-W>w

" Window travel
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-H> <C-W>h
noremap <C-L> <C-W>l

" Some shortcuts
nmap Y y$
nmap <Left>    :bp<CR>
nmap <Right>   :bn<CR>
nmap <S-Left>  gT
nmap <S-Right> gt

" When editing a file, always jump to the last known cursor position.  Don't
" do it when the position is invalid or when inside an event handler (happens
" when dropping a file on gvim). Also don't do it when the mark is in the
" first line, that is the default position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

autocmd FileType java setlocal noexpandtab
autocmd FileType python setlocal foldmethod=indent

let c_space_errors = 1
let python_highlight_all = 1
"let python_slow_sync = 1

let g:miniBufExplCheckDupeBufs = 0


autocmd BufRead,BufNewFile *.vx setfiletype verilog
