if has('win32') || has('win64')
    set guifont=DejaVu_Sans_Mono:h9:cANSI,Consolas:h9:cANSI
    set encoding=utf-8
elseif has('mac')
    set guifont=Menlo:h12
else
    set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 12,Ubuntu\ Mono\ 11
endif

set background=dark
colorscheme base16-tomorrow-night

set vb t_vb=
set guioptions-=T
set guioptions+=b
