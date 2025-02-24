
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

export PATH="$HOME/.npm-global/bin:$PATH"


export LIBGL_ALWAYS_INDIRECT=0
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_LOADER_DRIVER_OVERRIDE=i965 # Use `iris` for newer Intel GPUs
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json
export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d

# # from hyde config
#
# # cleaning up home folder
# XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
# XDG_CONFIG_DIR="${XDG_CONFIG_DIR:-HOME/.config}"
# XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
# XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
# XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
# XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
# XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
# XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$HOME/Templates}"
# XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$HOME/Public}"
# XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
# XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
# XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
# XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"
# LESSHISTFILE=${LESSHISTFILE:-/tmp/less-hist}
# PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
#
# # wget
# WGETRC="${XDG_CONFIG_HOME}/wgetrc"
# SCREENRC="$XDG_CONFIG_HOME"/screen/screenrc
#
# export XDG_CONFIG_HOME XDG_CONFIG_DIR XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_DESKTOP_DIR XDG_DOWNLOAD_DIR \
# XDG_TEMPLATES_DIR XDG_PUBLICSHARE_DIR XDG_DOCUMENTS_DIR XDG_MUSIC_DIR XDG_PICTURES_DIR XDG_VIDEOS_DIR
