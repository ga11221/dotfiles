" Plugin manager -----------------------------------------------------------

" Auto-install vim-plug if missing
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins ------------------------------------------------------------------

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'mattn/vim-goimports'
Plug 'github/copilot.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

" Appearance ---------------------------------------------------------------

syntax on
set background=light
colorscheme morning

" Undo persistence across sessions
set undofile
set undodir=~/.vim/undo

" Line numbers
set number

" New splits open below/right instead of above/left
set splitbelow
set splitright

" Filetype detection, plugins, and indentation
filetype plugin indent on

" Cursor shape -------------------------------------------------------------

if has("autocmd")
  " Block cursor in normal mode
  let &t_EI = "\e[2 q"
  " Line cursor in insert mode
  let &t_SI = "\e[5 q"
endif

" Go settings --------------------------------------------------------------

autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4
au FileType go nmap gr :GoReferrers<CR>
let g:goimports = 1

" Search -------------------------------------------------------------------

" Dictionary for keyword completion
set dictionary=/usr/share/dict/words

" Incremental search with highlighting
set incsearch
set hlsearch
set wrapscan

" Case-insensitive search unless uppercase is used
set ignorecase
set smartcase

" Copilot ------------------------------------------------------------------

" Point Copilot to nvm's node binary
let s:node_path = expand('~/.nvm/versions/node/v24.16.0/bin/node')
if filereadable(s:node_path)
  let g:copilot_node_command = s:node_path
endif

" Toggle Copilot on/off
function! s:CopilotToggle()
  if exists('g:copilot_enabled') && g:copilot_enabled
    Copilot disable
  else
    Copilot enable
  endif
endfunction
nnoremap <leader>ct :call <SID>CopilotToggle()<CR>

" Accept suggestion
imap <script><silent><nowait><expr> <C-l> copilot#Accept()
" Next/previous suggestion
imap <M-]> <Cmd>call copilot#Next()<CR>
imap <M-[> <Cmd>call copilot#Previous()<CR>
" Manually trigger suggestion
imap <C-;> <Cmd>call copilot#Suggest()<CR>

" Auto-save ----------------------------------------------------------------

" Save buffer 5s after last change, or immediately on focus loss
set updatetime=5000
autocmd CursorHold,CursorHoldI * update
autocmd FocusLost * update
