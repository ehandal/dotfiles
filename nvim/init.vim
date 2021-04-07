call plug#begin(stdpath('data') . '/plugged')

Plug 'christoomey/vim-tmux-navigator'
Plug 'edkolev/tmuxline.vim'
Plug 'godlygeek/tabular'
Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': './install --all --xdg' }
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

" use data dir
let g:netrw_home = stdpath('data')

" general settings
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

let g:python_highlight_all = 1

" general mappings
let mapleader = "\<space>"
noremap <Space> <Nop>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>n :nohlsearch<CR>
nnoremap <silent> <leader>t :Tags<CR>
nnoremap <silent> <leader>w :update<CR>

nmap Y y$
nmap <silent> <C-p> :bp<CR>
nmap <silent> <C-n> :bn<CR>

" airline settings
set noshowmode
let g:airline_extensions = ['branch', 'coc', 'tabline']
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#show_tab_type = 0

" tmuxline settings
let g:tmuxline_powerline_separators = 0
let g:tmuxline_preset = {
      \'a'       : '#S',
      \'win'     : ['#I', '#W'],
      \'cwin'    : ['#I', '#W'],
      \'z'       : '#H',
      \'options' :  {'status-justify' : 'left'}}

" coc.nvim settings
set updatetime=300
set cmdheight=2
set shortmess+=c
let g:coc_global_extensions = ['coc-json', 'coc-pyright']

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
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> Leader>d <Plug>(coc-definition)
nmap <silent> Leader>y <Plug>(coc-type-definition)
nmap <silent> Leader>i <Plug>(coc-implementation)
nmap <silent> Leader>r <Plug>(coc-references)
nmap <silent> Leader>e <Plug>(coc-rename)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

augroup coc
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    autocmd FileType c,cpp,python setlocal signcolumn=yes number
    autocmd FileType python let b:coc_root_patterns = ['__pycache__']
    autocmd FileType jsonc setlocal commentstring=//%s

    autocmd ColorScheme * highlight CocErrorHighlight cterm=undercurl gui=undercurl guisp=Red
                      \ | highlight CocWarningHighlight cterm=undercurl gui=undercurl guisp=Brown
                      \ | highlight CocInfoHighlight cterm=undercurl gui=undercurl guisp=Yellow
                      \ | highlight CocHintHighlight cterm=underline gui=underline guisp=#404040
augroup END

augroup misc
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif " :help last-position-jump
augroup END

set termguicolors
set background=dark
colorscheme base16-tomorrow-night
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
