
" Automatic installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin
call plug#begin('~/.config/nvim/plugged')

Plug 'ap/vim-css-color'
Plug 'benizi/vim-automkdir' "Automatically create missing folders on save
Plug 'benmills/vimux'
Plug 'bling/vim-airline'
Plug 'chr4/nginx.vim' 
Plug 'chrisbra/SudoEdit.vim'
Plug 'chriskempson/base16-vim'
Plug 'dylanaraps/wal.vim' "For wal https://github.com/dylanaraps/wal.vim
Plug 'farmergreg/vim-lastplace' "Restore cursor position
Plug 'joshdick/onedark.vim'
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
Plug 'tpope/vim-repeat'
Plug 'scrooloose/nerdcommenter'
Plug 'Raimondi/delimitMate'
Plug 'rking/ag.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/fish.vim',   { 'for': 'fish' }
Plug 'xolox/vim-misc'
Plug 'Yggdroot/indentLine'

call plug#end()
