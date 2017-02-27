if has('win32') || has('win64')
    set guifont=DejaVu_Sans_Mono:h9:cANSI,Consolas:h9:cANSI
    set encoding=utf-8
elseif has('mac')
    set guifont=Menlo:h12
else
    set guifont=Ubuntu\ Mono\ 11
endif

colorscheme asu1dark

set vb t_vb=
set guioptions-=T
set guioptions+=b
