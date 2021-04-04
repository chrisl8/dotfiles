
" plugin section

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

Plug 'blueshirts/darcula'

" Initialize plugin system
call plug#end()

colorscheme darcula
" I like it BLACK
hi Normal ctermbg=16 guibg=#000000
hi LineNr ctermbg=16 guibg=#000000
