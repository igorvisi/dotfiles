
" Automatic installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin
call plug#begin()

Plug 'navarasu/onedark.nvim'
Plug 'itchyny/lightline.vim'

Plug 'ap/vim-css-color'
Plug 'benizi/vim-automkdir' "Automatically create missing folders on save
Plug 'chr4/nginx.vim'
Plug 'chriskempson/base16-vim'
Plug 'farmergreg/vim-lastplace' "Restore cursor position
Plug 'junegunn/vim-emoji'
Plug 'junegunn/goyo.vim'
Plug 'kien/rainbow_parentheses.vim'
Plug 'mileszs/ack.vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'oplatek/Conque-Shell'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-markdown',     { 'for': 'markdown' }
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'Raimondi/delimitMate'
Plug 'xolox/vim-misc'
Plug 'Yggdroot/indentLine'

call plug#end()
