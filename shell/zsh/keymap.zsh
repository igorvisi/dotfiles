
# Updates editor information when the keymap changes.
function zle-keymap-select() {
  zle reset-prompt
  zle -R
}

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
  zle &&  zle -R
}

# Make Ctrl+Z toggle Ctrl+Z and fg
# credit: github.com/maximbaz/dotfiles/
my-ctrl-z() {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line -w
    else
        zle push-input -w
        zle clear-screen -w
    fi
}
zle -N my-ctrl-z

zle -N zle-keymap-select
zle -N edit-command-line


# vim bindings
bindkey -v
bindkey "jk" vi-cmd-mode
bindkey '^a'    vi-beginning-of-line
bindkey '^e'    vi-end-of-line
bindkey '^[[3~' vi-delete-char
bindkey '^l' vi-forward-word
bindkey '^[[1;3C' vi-forward-word
bindkey '^Z' my-ctrl-z
# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

# bind UP and DOWN arrow keys for history search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-beginning-search-backward
bindkey "$terminfo[kcud1]" history-beginning-search-forward
# Bind cltrl+j and cltrl+k arrow keys for history search
bindkey '^k' history-substring-search-down
bindkey '^j' history-substring-search-up

# [Esc] [Esc] for to add sudo
bindkey "\e\e" sudo-command-line
bindkey '^r' fzy-history-widget
bindkey '^f' fzy-file-widget
