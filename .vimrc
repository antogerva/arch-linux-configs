" Basics
syntax on               " enable syntax highlighting
set showmatch           " show matching brackets (),{},[]
set number
set nocompatible
set background=dark
set encoding=utf-8
set termencoding=utf-8 
filetype on
set complete=k          " global autocompletion
set completeopt+=longest

" Indenting, Folding..
set tabstop=4           " numbers of spaces of tab character
set shiftwidth=4        " numbers of spaces to (auto)indent
set softtabstop=4       " counts n spaces when DELETE or BCKSPCE is used
set expandtab           " insert spaces instead of tab chars
set autoindent         	" always set autoindenting on
set nosmartindent       " intelligent indenting -- DEPRECATED by cindent
set nocindent           " set C style indenting off
set foldenable
set foldmethod=marker

" searching
set hlsearch            " highlight all search results
set incsearch           " increment search
set ignorecase          " case-insensitive search
set smartcase           " upper-case sensitive search

set laststatus=2        " occasions to show status line, 2=always.
set cmdheight=1         " command line height
set ruler               " ruler display in status line
set showmode            " show mode at bottom of screen
" set previewheight=5

" Set taglist plugin options
let Tlist_Use_Right_Window = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Enable_Fold_Column = 0
let Tlist_Compact_Format = 1
let Tlist_File_Fold_Auto_Close = 0
let Tlist_Inc_Winwidth = 1

" Toggle taglist script
map <F7> :Tlist<CR>

" VTreeExplorer
map <F12> :VSTreeExplore <CR>
let g:treeExplVertical=1
let g:treeExplWinSize=35
let g:treeExplDirSort=1

" common save shortcuts
" inoremap <C-s> <esc>:w<cr>a
" nnoremap <C-s> :w<cr>

" Set bracket matching and comment formats
set matchpairs+=<:>
set comments-=s1:/*,mb:*,ex:*/
set comments+=s:/*,mb:**,ex:*/
set comments+=fb:*
set comments+=b:\"
set comments+=n::

" Fix filetype detection
au BufNewFile,BufRead .torsmorc* set filetype=rc
au BufNewFile,BufRead *.inc set filetype=php
au BufNewFile,BufRead *.sys set filetype=php
au BufNewFile,BufRead grub.conf set filetype=grub
au BufNewFile,BufRead *.dentry set filetype=dentry
au BufNewFile,BufRead *.blog set filetype=blog

" C file specific options
au FileType c,cpp set cindent
au FileType c,cpp set formatoptions+=ro

" HTML abbreviations
au FileType html,xhtml,php,eruby imap bbb <br />
au FileType html,xhtml,php,eruby imap aaa <a href=""><left><left>
au FileType html,xhtml,php,eruby imap iii <img src="" /><left><left><left><left>
au FileType html,xhtml,php,eruby imap ddd <div class=""><left><left>

" Session Settings
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winsize
map <c-q> :mksession! ~/.vim/.session <cr>
map <c-s> :source ~/.vim/.session <cr>

" Set up the status line
fun! <SID>SetStatusLine()
    let l:s1="%-3.3n\\ %f\\ %h%m%r%w"
    let l:s2="[%{strlen(&filetype)?&filetype:'?'},%{&encoding},%{&fileformat}]"
    let l:s3="%=\\ 0x%-8B\\ \\ %-14.(%l,%c%V%)\\ %<%P"
    execute "set statusline=" . l:s1 . l:s2 . l:s3
endfun
set laststatus=2
call <SID>SetStatusLine()

" Turn off blinking
set visualbell
" Turn off beep
set noerrorbells
set t_vb=

" highlight redundant whitespaces and tabs.
" highlight RedundantSpaces ctermbg=red guibg=red
" match RedundantSpaces /\s\+$\| \+\ze\t\|\t/

if has('gui_running')
    let &guicursor = &guicursor . ",a:blinkon0"
    colorscheme xoria256
    set guifont=MonteCarlo\ 12
    set guioptions-=T
    "set guioptions+=g
    "set guioptions-=t
    "set guioptions-=m
    set guioptions-=L
    set guioptions-=l
    set guioptions-=r
    set guioptions-=R
    set guitablabel=%t " set label for tab to just file name
    set anti " Antialias font
    "set transparency=0
elseif (&term =~ 'linux')
    set t_Co=16
    set mouse=a
    set termencoding=utf-8
    set nocursorline
    colorscheme desert
else
    set t_Co=256
    set mouse=a         
    colorscheme xoria256
    set termencoding=utf-8 
endif
