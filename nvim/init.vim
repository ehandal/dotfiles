call plug#begin(stdpath('data') . '/plugged')

Plug 'christoomey/vim-tmux-navigator'
Plug 'edkolev/tmuxline.vim'
Plug 'godlygeek/tabular'
Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': 'ZDOTDIR=$HOME/.config/zsh ./install --all --xdg' }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/jsonc.vim'
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
nmap <C-p> :bp<CR>
nmap <C-n> :bn<CR>

let mapleader = "\<space>"
noremap <Space> <Nop>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>n :nohlsearch<CR>
nnoremap <silent> <leader>t :Tags<CR>
nnoremap <silent> <leader>w :update<CR>

" coc.nvim related settings
set updatetime=300
set cmdheight=2
set shortmess+=c

" coc.nvim mappings
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nmap <Leader>d <Plug>(coc-definition)
nmap <Leader>y <Plug>(coc-type-definition)
nmap <Leader>i <Plug>(coc-implementation)
nmap <Leader>r <Plug>(coc-references)
nmap <Leader>e <Plug>(coc-rename)

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    autocmd FileType c,cpp,python setlocal signcolumn=number number
    autocmd FileType python let b:coc_root_patterns = ['__pycache__']
    autocmd FileType jsonc setlocal commentstring=//%s
augroup end

" :help last-position-jump
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

let g:netrw_home = stdpath('data')
let g:python_highlight_all = 1

set termguicolors
set background=dark
colorscheme base16-tomorrow-night
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
