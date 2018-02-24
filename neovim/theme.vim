set t_Co=256 " Explicitly tell vim that the terminal supports 256 colors
if &term =~ '256color'
		" disable background color erase
		set t_ut=
	endif

	" enable 24 bit color support if supported
	if (has('mac') && empty($TMUX) && has("termguicolors"))
		set termguicolors
	endif

	" highlight conflicts
	match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
" Colorscheme and final setup 
	" This call must happen after the plug#end() call to ensure
	" that the colorschemes have been loaded
	if filereadable(expand("~/.vimrc_background"))
		let base16colorspace=256
		source ~/.vimrc_background
	else
		let g:onedark_termcolors=16
		let g:onedark_terminal_italics=1
		colorscheme onedark
	endif
	syntax on
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
	highlight LineNr  ctermfg=grey



	" Airline
		let g:airline_powerline_fonts=1
		let g:airline_left_sep=''
		let g:airline_right_sep=''
		let g:airline_theme='base16'
		let g:airline#extensions#tabline#show_splits = 0
		let g:airline#extensions#whitespace#enabled = 0
		" enable airline tabline
		let g:airline#extensions#tabline#enabled = 1
		" only show tabline if tabs are being used (more than 1 tab open)
		let g:airline#extensions#tabline#tab_min_count = 2
		" do not show open buffers in tabline
		let g:airline#extensions#tabline#show_buffers = 0


