" Pleb mode deactivated
"no <Down> <Nop>
"no <Up> <Nop>
"no <Left> <Nop>
"no <Right> <Nop>
"ino <Down> <Nop>
"ino <Up> <Nop>
"ino <Left> <Nop>
"vno <Down> <Nop>
"vno <Up> <Nop>
"vno <Left> <Nop>
"vno <Right> <Nop>

" jk for escape
imap jk <Esc>
vno  jk <Esc> 

" zz for save and quit
imap zz <Esc> :x <CR>
nnoremap zz :x <CR>

nnoremap zw :w <CR>
" clear search highlighting
nnoremap <silent> <leader>l :nohlsearch<CR><C-l>

" Relaod vim conf
nnoremap <leader>sv :source $MYVIMRC<cr>

" Switch between tabs
noremap <tab> gt
noremap <s-tab> gT

" split (,s) for horizontal and (,v) for vertical
map <leader>s :split<CR>
map <leader>v :vsplit<CR>

"Just in case I can not find
"these on the keyboard
inoremap ww <
inoremap WW >

" Navigate between split
map <C-j> <C-W>j¬
map <C-k> <C-W>k¬
map <C-H> <C-W>h¬
map <C-L> <C-W>l¬

" Yank from cursor to end of line
nnoremap Y y$

" Insert newline after
map <leader>o o<ESC>
" Insert newline before
map <leader>O O<ESC>


" Speed up viewport scrolling
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" Sudo write (,w)
noremap <leader>w :w !sudo tee %<CR>
