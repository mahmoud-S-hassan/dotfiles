
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
