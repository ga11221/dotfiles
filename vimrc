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
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()

" Appearance ---------------------------------------------------------------

syntax on
set background=dark
colorscheme dracula
highlight Comment ctermfg=gray guifg=#808080

" Undo persistence across sessions
set undofile
set undodir=~/.vim/undo

" Command history — persist 2000 entries across sessions
set history=2000
set viminfo='1000,:2000

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

" coc.nvim (LSP client) ----------------------------------------------------

" Auto-install coc-java extension
let g:coc_global_extensions = ['coc-java']

" Tab for completion navigation; Enter to confirm
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <silent><expr> <S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" LSP navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <leader>rn <Plug>(coc-rename)

" Auto-save ----------------------------------------------------------------

" Save buffer 5s after last change, or immediately on focus loss
set updatetime=5000
autocmd CursorHold,CursorHoldI * update
autocmd FocusLost * update

" TODO: test coc-java with standalone .java file outside OpenSearch project
"       mkdir -p /tmp/javatest/src
"       cd /tmp/javatest && vim src/Hello.java
"       gd on local var and method call — if works, issue is OpenSearch Gradle import
"
" Persist folds ------------------------------------------------------------

autocmd BufWritePost,BufLeave * silent! mkview
autocmd BufReadPost * silent! loadview
