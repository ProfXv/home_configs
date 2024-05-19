unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

set nu
set hls

autocmd BufNewFile,BufRead *.wl set syntax=wl
autocmd BufNewFile,BufRead *.wls set syntax=wl
autocmd BufNewFile,BufRead *.m set syntax=wl
