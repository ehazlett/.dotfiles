set nocompatible
filetype off
set shell=/bin/bash

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
" theme
Plugin 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'fatih/vim-go'
Plugin 'tpope/vim-surround'
Plugin 'jiangmiao/auto-pairs'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'hashivim/vim-terraform'
Bundle 'uarun/vim-protobuf'
Plugin 'mdempsky/gocode', {'rtp': 'vim/'}
Plugin 'posva/vim-vue'

call vundle#end()

filetype plugin indent on

set encoding=utf-8
set modelines=0
set showmode
set showcmd
set shell=/bin/bash
set tabstop=8
set shiftwidth=8
set softtabstop=8
set noexpandtab
set nohlsearch
set nu
"set cc=80
set tenc=utf8
syntax on
let g:hybrid_use_Xresources = 1

" theme
set t_Co=256
hi Normal ctermbg=none
"colorscheme Tomorrow

"let g:airline_theme='tomorrow'
let NERDTreeIgnore = ['\.pyc$']
set backspace=indent,eol,start
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

autocmd BufWritePre * :%s/\s\+$//e

au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
au FileType go nmap <Leader>ds <Plug>(go-def-split)
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>dt <Plug>(go-def-tab)
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

" yml
au FileType yml setl sw=2 sts=2 et
" proto
au FileType proto setl sw=8 sts=8 et
" js
au FileType javascript setl sw=2 sts=2 et
au FileType vue setl sw=2 sts=2 et

let g:go_fmt_command = "goimports"

let g:go_highlight_functions = 1
let g:go_highlight_fields = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

" terraform
let g:terraform_align=1

" Open go doc in vertical window, horizontal, or tab
au Filetype go nnoremap <leader>v :vsp <CR>:exe "GoDef" <CR>
au Filetype go nnoremap <leader>s :sp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>t :tab split <CR>:exe "GoDef"<CR>

" autocomplete navigation
inoremap <expr> j ((pumvisible())?("\<C-n>"):("j"))
inoremap <expr> k ((pumvisible())?("\<C-p>"):("k"))
