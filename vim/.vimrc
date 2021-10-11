" Attempt to determine the type of a file based on its name and possibly its contents. Use this to allow intelligent auto-indenting for each filetype, and for plugins that are filetype specific.
filetype indent plugin on
 
" Enable syntax highlighting
syntax on

" Instead of failing a command because of unsaved changes, instead raise a dialogue asking if you wish to save changed files.
set confirm

" Display line numbers on the left
set number

" Display the cursor position on the last line of the screen or in the status line of a window
set ruler

" Use visual bell instead of beeping when doing something wrong
set visualbell

"------------
" Indentation options

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=4
set softtabstop=4
set expandtab
