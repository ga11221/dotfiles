" Install vim-plug if not present
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" Your plugins here
Plug 'tpope/vim-sensible'
Plug 'mattn/vim-goimports'
Plug 'github/copilot.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

syntax on
set background=light
colorscheme morning
set undofile
set undodir=~/.vim/undo
set number
set viminfo='100
filetype plugin indent on

"set guicursor=n-v-c:block
if has("autocmd")
  " Set block cursor in normal mode (Ps=1 or 2)
  let &t_EI = "\e[2 q"
  " Set line cursor in insert mode (Ps=5 or 6)
  let &t_SI = "\e[5 q"
endif

autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4

set dictionary=/usr/share/dict/words
set incsearch
set hlsearch
set wrapscan
set ignorecase
set smartcase

"let g:go_fmt_command = "goimports"
au FileType go nmap gr :GoReferrers<CR>
" enable auto format when write (default)
let g:goimports = 1

" Point Copilot to nvm's node
let s:node_path = expand('~/.nvm/versions/node/v24.16.0/bin/node')
if filereadable(s:node_path)
  let g:copilot_node_command = s:node_path
endif

" Copilot key mappings
function! s:CopilotToggle()
  if exists('g:copilot_enabled') && g:copilot_enabled
    Copilot disable
  else
    Copilot enable
  endif
endfunction
nnoremap <leader>ct :call <SID>CopilotToggle()<CR>
imap <script><silent><nowait><expr> <C-l> copilot#Accept()
imap <M-]> <Cmd>call copilot#Next()<CR>
imap <M-[> <Cmd>call copilot#Previous()<CR>
imap <C-;> <Cmd>call copilot#Suggest()<CR>

" Auto-save 5s after last change (normal + insert mode)
set updatetime=5000
autocmd CursorHold,CursorHoldI * update
