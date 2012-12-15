" set default 'runtimepath' (without ~/.vim folders)
let &runtimepath = printf('%s,%s,%s/after', $VIM, $VIMRUNTIME, $VIM)

" what is the name of the directory containing this file?
let s:portable = expand('<sfile>:p:h')

" add the directory to 'runtimepath'
let &runtimepath = printf('%s,%s,%s/after', s:portable, &runtimepath, s:portable)


call pathogen#infect()
syntax on
filetype plugin indent on
filetype on



" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
set shellslash

" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*


" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'



let $MYVIMRC = $HOME."/Dropbox/Vim/vimrc.vim"
let $VIMFolder = $HOME."/Dropbox/Vim/"


" /*** FlutePlayer Plugin ****/

let $FlutePlayer = $VIMFolder."bundle/FlutePlayer.vim"
source $FlutePlayer

" /*** Vim Interface  ***/

set wildmenu
set ignorecase
set hls
set number
set ruler
set showmatch
set ls=2
set iskeyword+=_,$,@,%,#  
set foldmethod=marker

set cf  " Enable error files & error jumping.
set clipboard+=unnamed  " Yanks go on clipboard instead.
set history=256  " Number of things to remember in history.
set autowrite  " Writes on make/shell commands
set timeoutlen=250  " Time to wait after ESC (default causes an annoying delay)
" colorscheme vividchalk  " Uncomment this to set a default theme


"adding more history (default 20)
set history=1000
	
"Formatting

set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
" set expandtab "ignoring tabs putting spaces raplacing tabs




" /*** Background  ***/
so ~/DropBox/Vim/Colors/wombat256mod.vim


" /*** NERDTree Config ***/

if $CurrentSystem == 'WorkMac'
" autocmd VimEnter * NERDTree /private/tmp/
" autocmd VimEnter * /[ ][0-9]\+
" autocmd VimEnter * let VmID = expand("<cword>")
" autocmd VimEnter * let WindowsC =  "/private/tmp/".VmID."/C/"
" autocmd VimEnter * wincmd p
" autocmd VimEnter * NERDTreeToggle
endif
	
nmap <silent> <leader>v :NERDTree $VIMFolder<CR>
nmap <silent> <leader>vb :NERDTree $VIMFolder/bundle<CR>
nmap <silent> <leader>n :NERDTreeToggle<CR>

"Command line map
nnoremap ; :


" file types

exec 'au FileType tex so '.$VIMFolder.'bundle/ftplugin/tex_latexSuite.vim'

let g:ruby_debugger_progname = 'mvim'
 let g:ruby_debugger_no_maps = 1
 let g:ruby_debugger_builtin_sender = 0


 "Window faster moves
 map <C-j> <C-w><C-j>
 map <C-k> <C-w><C-k>
 map <C-h> <C-w><C-h>
 map <C-l> <C-w><C-l>

 "Open Terminal
command! Terminal silent exec '!osascript -e "tell application \"Terminal\" to do script \"cd '.getcwd().'; clear\"" > /dev/null'

 "Open Finder
command! Finder silent execute "!open %:h"
command! RFinder silent execute "!open ".getcwd()
