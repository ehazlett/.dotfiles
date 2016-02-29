set nocompatible
filetype off
set shell=/bin/bash

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'gmarik/vundle'
Plugin 'altercation/vim-colors-solarized'
Plugin 'w0ng/vim-hybrid'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'rodjek/vim-puppet'
Plugin 'Blackrush/vim-gocode'
Plugin 'jiangmiao/auto-pairs'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'nanotech/jellybeans.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()

filetype plugin indent on

autocmd BufWritePre *.go Fmt
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
