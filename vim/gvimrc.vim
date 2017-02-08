if has('win32') || has('win64')
    set guifont=Bitstream_Vera_Sans_Mono:h9:cANSI,Consolas:h9:cANSI
elseif has('mac')
    set guifont=Menlo:h12
else
    set guifont=Monospace\ 9
endif

colorscheme asu1dark

set vb t_vb=
set guioptions-=T
set guioptions+=b
