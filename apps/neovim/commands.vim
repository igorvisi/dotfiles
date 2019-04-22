"-- For mitigating common command mistakes --"
command! W w
command! Wq wq
command! WQ wq
command! Q q
command! Qa qa
command! QA qa

"-- User defined commands for config files --"
command! Alias   :e ~/.aliases
command! Func    :e ~/.functions
command! I3conf  :e ~/.config/i3/config
command! Polyb   :e ~/.config/polybar/config
command! Vimrc   :e ~/.config/nvim
command! Tmx     :e ~/.tmux.conf
command! Zshrc   :e ~/.zshrc


