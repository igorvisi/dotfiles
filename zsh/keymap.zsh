
# Updates editor information when the keymap changes.
function zle-keymap-select() {
  zle reset-prompt
  zle -R
}

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
  zle &&  zle -R
}

zle -N zle-keymap-select
zle -N edit-command-line


# vim bindings
bindkey -v
bindkey "jk" vi-cmd-mode
bindkey -M viins "  " magic-space  # double space to make a normal space from globalias (oh-my-zsh plugin)
bindkey '^a'    vi-beginning-of-line
bindkey '^e'    vi-end-of-line
bindkey '^[[3~' vi-delete-char 


bindkey '^[[1;3C' vi-forward-word
# bind UP and DOWN arrow keys for history search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-beginning-search-backward
bindkey "$terminfo[kcud1]" history-beginning-search-forward
# Bind cltrl+j and cltrl+k arrow keys for history search
bindkey '^k' history-substring-search-down
bindkey '^j' history-substring-search-up

# Defined shortcut keys: [Esc] [Esc]
bindkey "\e\e" sudo-command-line

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

# allow ctrl-r to perform backward search in history
bindkey '^r' history-incremental-search-backward

# if mode indicator wasn't setup by theme, define default
if [[ "$MODE_INDICATOR" == "" ]]; then
  MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[red]%}<<%{$reset_color%}"
fi

function vi_mode_prompt_info() {
  echo "${${KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}

# define right prompt, if it wasn't defined by a theme
if [[ "$RPS1" == "" && "$RPROMPT" == "" ]]; then
  RPS1='$(vi_mode_prompt_info)'
fi

