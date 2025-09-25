
export XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS"
export PATH=$PATH:/var/lib/snapd/snap/bin
# export DOCKER_HOST=unix:///home/abo-salah/.docker/desktop/docker.sock

# export DOCKER_HOST=unix:///var/run/docker.sock
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/apps/manage_session:$PATH"

export FZF_CTRL_T_OPTS="--preview='less {}' --height=50% --bind shift-up:preview-page-up,shift-down:preview-page-down,alt-space:toggle+down"
export FZF_COMPLETION_OPTS="--bind=alt-space:toggle+down"

#path for typeScript
export PATH=~/.npm-global/bin:$PATH

#export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
# export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/usr/share/dotnet/sdk:$PATH"
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$DOTNET_ROOT:$PATH

export PATH="$HOME/.npm-global/bin:$PATH"

# Add JetBrains Rider to PATH if it exists
JETBRAINS_DIR="$HOME/.local/share/JetBrains/Toolbox/apps"

if [ -d "$JETBRAINS_DIR/rider/bin" ]; then
    export PATH="$PATH:$JETBRAINS_DIR/rider/bin"
fi
export PATH="$PATH:/home/abo-salah/.dotnet/tools"

export XDG_DATA_DIRS=$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS
# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/abo-salah/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="/opt/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/opt/cuda/lib64:$LD_LIBRARY_PATH"
export CUDA_HOME="/opt/cuda"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/abo-salah/.dart-cli-completion/zsh-config.zsh ]] && . /home/abo-salah/.dart-cli-completion/zsh-config.zsh || true

## path for coustom scripts
PATH="$HOME/dotfiles/scripts/msi-brightness/:$PATH"
