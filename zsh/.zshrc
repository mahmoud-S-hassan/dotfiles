# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light paulirish/git-open

# Plugin history-search-multi-word loaded with investigating.
zinit load zdharma-continuum/history-search-multi-word

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word
bindkey '^H' backward-kill-word
# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

eval "$(zoxide init zsh)"




# Helpful aliases
alias c='clear' # clear terminal
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code' # gui code editor
alias la='exa -alh'
# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'



alias cl=clear
alias c=clear
alias e=exit
alias v=nvim

#alias for nvims with fzf
alias va=nvim-astro
alias vl=nvim-lazy
alias vd=nvim-DEVASLIFE

alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias nvim-DEVASLIFE="NVIM_APPNAME=DEVASLIFE nvim"
alias nvim-Grim="NVIM_APPNAME=nvimGrim nvim"
alias nvim-gg="NVIM_APPNAME=nvimgg nvim"

function nvims() {
    items=("default" "kickstart" "DEVASLIFE" "LazyVim" "NvChad" "AstroNvim" "nvimGrim" "nvimgg")
    config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
    if [[ -z $config ]]; then
        echo "Nothing selected"
        return 0
    elif [[ $config == "default" ]]; then
        config=""
    fi
    NVIM_APPNAME=$config nvim $@
}

bindkey -s ^a "nvims\n"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



gcop() {
    git log \
        --reverse \
        --color=always \
        --format="%C(cyan)%h %C(blue)%ar%C(auto)%d \
        %C(yellow)%s%+b %C(black)%ae" "$@" |
    fzf -i -e +s \
        --reverse \
        --tiebreak=index \
        --no-multi \
        --ansi \
        --preview="echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'" \
        --header "enter: view, C-c: copy hash" \
        --bind "enter:execute:_viewGitLogLine {} | less -R" \
        --bind "ctrl-c:execute:_gitLogLineToHash {} | xclip -r -selection clipboard"
}

_viewGitLogLine() {
    local commit_hash="$1"
    git show --color=always "$commit_hash" | less -r
}

_gitLogLineToHash() {
    local commit_line="$1"
    local commit_hash=$(echo "$commit_line" | grep -o '[a-f0-9]\{7\}' | head -1)
    echo "$commit_hash" | xclip -r -selection clipboard
}

#-----------------------------------------------------------------------------#
# Function to handle directory changes using fzf
function _fzf_change_directory {
    local foo
    foo=$(printf "%s\n" "${directories[@]}" | fzf --prompt="🗂 Select Directory → " --height=50% --layout=reverse --border --exit-0)
    if [ "$foo" ]; then
        builtin cd "$foo"
    fi
}

# Main function to list and navigate directories using fzf
function fzf_change_directory {
    local directories
    directories=($(echo "$HOME/.config"
        # Check if ghq root exists or remove this line if not needed
        [ -d "$(ghq root)" ] && find "$(ghq root)" -maxdepth 4 -type d -name .git | sed 's/\/\.git//'
        ls -ad */ | perl -pe "s#^#$PWD/#" | grep -v \.git
        # Check if Developments exists and contains directories
        if [ -d "$HOME/Developments" ]; then
            ls -ad $HOME/Developments/*/* | grep -v \.git
        fi
    ))

    if [ ${#directories[@]} -eq 0 ]; then
        echo "No directories found!"
        return
    fi

    _fzf_change_directory
}

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
#open a photo for now until I know more
alias o='xdg-open'

alias dr='dotnet run'
alias fz="find . -type f | fzf --preview 'bat --style=numbers --color=always -- {}'"
#path for typeScript
export PATH=~/.npm-global/bin:$PATH

#export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"

# WSL 2 specific settings.
#export DISPLAY="$(/sbin/ip route | awk '/default/ { print $3 }'):0"

#lunch whatsapp 


# costumizing for personal 
pokemon-colorscripts --no-title -r 1,3,6
