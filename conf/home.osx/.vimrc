" nocompatible should be set before everything
set nocompatible

syntax on

set background=dark

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Uncomment the following to have Vim jump to the last position when
  " reopening a file
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

  " Uncomment the following to have Vim load indentation rules and plugins
  " according to the detected filetype.
  filetype plugin indent on

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
"set hidden             " Hide buffers when they are abandoned
set mouse=a		" Enable mouse usage (all modes)

" allow backspacing over everything in insert mode
set backspace=indent,eol,start


" custom settings
set nobackup
set confirm
"set expandtab
set history=50		" keep 50 lines of command line history
set hlsearch
set number		" print the line number in front of each line
set ruler		" show the cursor position all the time
set shiftwidth=4
set smartindent
set smarttab
set splitright
set splitbelow
set tabstop=4
set updatetime=60000
set wildmenu

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	 	\ | wincmd p | diffthis

" disable beep and bell
"set visualbell
"set t_vb=

"nnoremap <C-L> :nohl<CR><C-L>

" syntax folding
set foldmethod=syntax
let g:php_folding=1
let javaScript_fold=1
let sh_fold_enabled=1         " sh
let xml_syntax_folding=1      " XML
"let perl_fold=1               " Perl
"let r_syntax_folding=1        " R
"let ruby_fold=1               " Ruby
"let vimsyn_folding='af'       " Vim script

" more colors
set t_Co=256
"colorscheme elflord
"highlight DiffAdd ctermfg=Yellow
"hi DiffAdd ctermbg=160
"hi DiffChange ctermbg=black
"hi DiffDelete ctermbg=25
"hi DiffText cterm=none ctermbg=240

"set completeopt=longest,menuone

" php syntax check
"map <C-B> :!php -l %<CR>
nnoremap <Leader>sp :w !php -l<CR>
" open php manual for current word
"noremap <Leader>mp ! iceweasel [http://php.net/<cword><CR> http://php.net/<cword><CR>];
"noremap <Leader>mp :!iceweasel http://php.net/<cword><CR> 

" plugin settings
"nnoremap <silent> <F8> :TlistToggle<CR>
"nnoremap <Leader>tt :TlistToggle<CR>

