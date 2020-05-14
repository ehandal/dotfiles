call plug#begin(stdpath('data') . '/plugged')

Plug 'christoomey/vim-tmux-navigator'
Plug 'edkolev/tmuxline.vim'
Plug 'godlygeek/tabular'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'
Plug 'vim-python/python-syntax'

" colorschemes
Plug 'chriskempson/base16-vim'
Plug 'frankier/neovim-colors-solarized-truecolor-only'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

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
      \'options' :  {'status-justify' : 'left'}}

set hidden
set virtualedit=block
set wildmode=longest:full,full
set tabstop=4
set shiftwidth=4
set expandtab
set mouse=a
set undofile
set nowrap

set ignorecase
set smartcase

nmap Y y$
nmap <Left>  :bp<CR>
nmap <Right> :bn<CR>

let mapleader = "\<space>"
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>n :nohlsearch<CR>
nnoremap <silent> <leader>t :Tags<CR>
nnoremap <silent> <leader>w :update<CR>

" :help last-position-jump
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

let g:python_highlight_all = 1

set termguicolors
set background=dark
colorscheme base16-tomorrow-night
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
