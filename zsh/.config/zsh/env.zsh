
export XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS"
export PATH=$PATH:/var/lib/snapd/snap/bin
export DOCKER_HOST=unix:///home/abo-salah/.docker/desktop/docker.sock

export DOCKER_HOST=unix:///var/run/docker.sock
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/apps/manage_session:$PATH"

export FZF_CTRL_T_OPTS="--preview='less {}' --height=50% --bind shift-up:preview-page-up,shift-down:preview-page-down,alt-space:toggle+down"
export FZF_COMPLETION_OPTS="--bind=alt-space:toggle+down"

#path for typeScript
export PATH=~/.npm-global/bin:$PATH

#export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
