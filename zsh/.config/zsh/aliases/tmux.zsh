
#alias t='tmux attach || tmux new-session\; new-window\; new-window'

# Some tmux-related shell aliases

# Attaches tmux to the last session; creates a new session if none exists.
alias t='tmux attach || tmux new-session'

# Attaches tmux to a session (example: ta portal)
alias ta='tmux attach -t'

# Creates a new session
alias tn='tmux new-session'

# Lists all ongoing sessions
alias tl='tmux list-sessions'
# tmux new-window
alias tw='tmux neww'

alias kt='$HOME/dotfiles/scripts/tmux/kill_sessions.sh'
