
# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word
bindkey '^H' backward-kill-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

bindkey -s '^[s' "fzf_change_directory\n"
