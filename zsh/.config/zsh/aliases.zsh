
# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
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
alias vk=nvim-kick
alias vd=nvim-DEVASLIFE

alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias nvim-DEVASLIFE="NVIM_APPNAME=DEVASLIFE nvim"
alias nvim-Grim="NVIM_APPNAME=nvimGrim nvim"
alias nvim-gg="NVIM_APPNAME=nvimgg nvim"


#open a photo for now until I know more
alias o='xdg-open'

alias dr='dotnet run'
alias fz="find . -type f | fzf --preview 'bat --style=numbers --color=always -- {}'"

#Git aliases
alias hist="git log --pretty=format:'%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(auto)%d%C(reset)' --graph --date=relative --decorate --all"
alias llog="git log --graph --name-status --pretty=format:'%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset' --date=relative"
