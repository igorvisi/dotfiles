set t_Co=256 " Explicitly tell vim that the terminal supports 256 colors
	" highlight conflicts
	match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
" Colorscheme and final setup
	" This call must happen after the plug#end() call to ensure
	" that the colorschemes have been loaded
	syntax on
	set termguicolors     " enable true colors support
	colorscheme onedark
	filetype plugin indent on
	" make the highlighting of tabs and other non-text less annoying
	highlight SpecialKey ctermfg=black
	highlight NonText ctermfg=black
	highlight Comment ctermfg=black

	" make comments and HTML attributes italic
	highlight Comment cterm=italic
	highlight htmlArg cterm=italic
	highlight xmlAttrib cterm=italic
	highlight Type cterm=italic
	highlight Normal ctermbg=none
	highlight Normal ctermfg=grey

	" Lightline
	let g:lightline = {
		\ 'colorscheme': 'one',
		\ }
