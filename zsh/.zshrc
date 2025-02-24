# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


source_all_files() {
    local config_dir="$HOME/dotfiles/zsh/.config/zsh"

    # Source prompt.zsh first
    source "$config_dir/prompt.zsh"

    # source all other .zsh files (excluding prompt.zsh)
    for file in "$config_dir"/*.zsh; do
        # Check if the file actually exists before sourcing
        if [[ -f $file  && "$file" != "$config_dir/prompt.zsh" ]]; then
            source "$file"
        fi
    done
}

# Call the function to source all .zsh files
source_all_files

## costumizing for personal 
#pokemon-colorscripts --no-title -r 1,3,6

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
