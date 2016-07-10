set nocompatible
filetype off
set shell=/bin/bash

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'gmarik/vundle'
Plugin 'w0ng/vim-hybrid'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'fatih/vim-go'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/syntastic'
Plugin 'jiangmiao/auto-pairs'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()

filetype plugin indent on

set t_Co=256
set cursorline
set encoding=utf-8
set modelines=0
set showmode
set showcmd
set shell=/bin/bash
set colorcolumn=+1
set tabstop=8
set shiftwidth=4
set softtabstop=4
set expandtab
set nohlsearch
set nu
set cc=80
set background=dark
syntax on
let g:hybrid_use_Xresources = 1
colorscheme hybrid
"colorscheme jellybeans
let NERDTreeIgnore = ['\.pyc$']
set backspace=indent,eol,start
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
highlight ColorColumn guibg=lightgrey ctermbg=lightgrey
highlight Directory guifg=#ff0000 ctermfg=blue
let g:airline_theme='hybridline'

let g:syntastic_check_on_wq = 0
autocmd BufWritePre * :%s/\s\+$//e

au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
au FileType go nmap <Leader>ds <Plug>(go-def-split)
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>dt <Plug>(go-def-tab)
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

let g:go_fmt_command = "goimports"

let g:go_highlight_functions = 1
let g:go_highlight_fields = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

let g:syntastic_go_checkers = ['go', 'golint', 'errcheck']

" Open go doc in vertical window, horizontal, or tab
au Filetype go nnoremap <leader>v :vsp <CR>:exe "GoDef" <CR>
au Filetype go nnoremap <leader>s :sp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>t :tab split <CR>:exe "GoDef"<CR>
