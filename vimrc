set nocompatible
filetype off
set shell=/bin/bash

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/vundle'
Plugin 'altercation/vim-colors-solarized'
Plugin 'scrooloose/nerdtree'
Plugin 'Lokaltog/vim-powerline'
Plugin 'kien/ctrlp.vim'
Plugin 'rodjek/vim-puppet'
Plugin 'jnwhiteh/vim-golang'
Plugin 'jiangmiao/auto-pairs'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'

call vundle#end()
filetype plugin indent on

autocmd BufWritePre *.go Fmt
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
let NERDTreeIgnore = ['\.pyc$']
set backspace=indent,eol,start
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc
colorscheme solarized
let g:solarized_termtrans = 1
autocmd vimenter * if !argc() | NERDTree | endif
