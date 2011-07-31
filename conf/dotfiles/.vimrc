" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2006 Nov 16
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
"set nocompatible

" allow backspacing over everything in insert mode
"set backspace=indent,eol,start

" if has("vms")
"   set nobackup		" do not keep a backup file, use versions instead
" else
"   set backup		" keep a backup file
" endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
"map Q gq

" In many terminal emulators the mouse works just fine, thus enable it.
"set mouse=a

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
"if &t_Co > 2 || has("gui_running")
"  syntax on
"  set hlsearch
"endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
"  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
"  autocmd BufReadPost *
"    \ if line("'\"") > 0 && line("'\"") <= line("$") |
"    \   exe "normal! g`\"" |
"    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	 	\ | wincmd p | diffthis

" disable beep and bell
"set visualbell
"set t_vb=

"highlight DiffAdd ctermfg=Yellow
"nnoremap <C-L> :nohl<CR><C-L>

" most vimrc config were already done in /etc/vim/vimrc

set foldmethod=syntax
let g:php_folding=1
let javaScript_fold=1
let sh_fold_enabled=1         " sh
let xml_syntax_folding=1      " XML
"let perl_fold=1               " Perl
"let r_syntax_folding=1        " R
"let ruby_fold=1               " Ruby
"let vimsyn_folding='af'       " Vim script

set t_Co=256
colorscheme elflord
hi DiffAdd ctermbg=160
hi DiffChange ctermbg=black
hi DiffDelete ctermbg=25
hi DiffText cterm=none ctermbg=240

:set completeopt=longest,menuone

" php syntax check
"map <C-B> :!php -l %<CR>
nnoremap <Leader>sp :w !php -l<CR>
" open php manual for current word
"noremap <Leader>mp ! iceweasel [http://php.net/<cword><CR> http://php.net/<cword><CR>];
noremap <Leader>mp :!iceweasel http://php.net/<cword><CR> 

" plugin settings
"nnoremap <silent> <F8> :TlistToggle<CR>
nnoremap <Leader>tt :TlistToggle<CR>

