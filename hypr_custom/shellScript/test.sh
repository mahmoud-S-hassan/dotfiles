#!/bin/bash

# Base directory containing subdirectories with wallpapers
BASE_WALLPAPER_DIR="/mnt/winDrive/TOOLS/walls-main"

# Multiple wallpaper directories (including all subdirectories of walls-main)
BACKGROUND_DIRS=(
  "$HOME/.config/omarchy/current/theme/backgrounds/"
  # "$HOME/Pictures/Wallpapers/"
  # "$HOME/Pictures/Backgrounds/"
)

# Add all subdirectories from walls-main
if [[ -d "$BASE_WALLPAPER_DIR" ]]; then
  while IFS= read -r -d '' subdir; do
    if [[ -d "$subdir" ]]; then
      BACKGROUND_DIRS+=("$subdir")
    fi
  done < <(find "$BASE_WALLPAPER_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
fi

CURRENT_BACKGROUND_LINK="$HOME/.config/omarchy/current/background"

# Directory for notifications (if needed)
iDIR="$HOME/.config/swaync/images"

# Variables
rofi_theme="$HOME/.config/rofi/config-wallpaper.rasi"

# Check if rofi is available for menu mode
if [[ "$1" == "--menu" ]] || [[ "$1" == "-m" ]]; then
  if ! command -v rofi &>/dev/null; then
    echo "rofi not found, required for menu mode"
    exit 1
  fi

  # Simple icon sizing
  rofi_override="element-icon{size:30%;}"
  rofi_command="rofi -i -show -dmenu -config $rofi_theme -theme-str '$rofi_override'"
fi

# Retrieve wallpapers from ALL directories (images only)
mapfile -d '' PICS < <(
  for dir in "${BACKGROUND_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      find -L "${dir}" -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
        -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o -iname "*.mp4" \) -print0 2>/dev/null
    fi
  done
)

# If no wallpapers found
if [[ ${#PICS[@]} -eq 0 ]]; then
  notify-send "No backgrounds found in any directory" -t 2000
  pkill -x swaybg
  setsid uwsm app -- swaybg --color '#000000' >/dev/null 2>&1 &
  exit 0
fi

RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME=". random"

menu() {
  IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))

  printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"

  for pic_path in "${sorted_options[@]}"; do
    pic_name=$(basename "$pic_path")
    # Show directory name in menu for better organization
    dir_name=$(dirname "$pic_path")
    base_dir=$(basename "$dir_name")
    display_name="[$base_dir] $(echo "$pic_name" | cut -d. -f1)"
    printf "%s\x00icon\x1f%s\n" "$display_name" "$pic_path"
  done
}

# set_background() {
#   local background_path="$1"
#   ln -nsf "$background_path" "$CURRENT_BACKGROUND_LINK"
#   pkill -x swaybg
#   setsid uwsm app -- swaybg -i "$CURRENT_BACKGROUND_LINK" -m fill >/dev/null 2>&1 &
#   bg_name=$(basename "$background_path")
#   notify-send "Background Set" "$bg_name" -t 2000
# }

set_background() {
  local background_path="$1"
  ln -nsf "$background_path" "$CURRENT_BACKGROUND_LINK"

  # Kill any existing background processes
  pkill -x swaybg
  pkill -x mpvpaper

  if [[ "$background_path" == *.mp4 ]]; then
    # Handle video files with mpvpaper
    setsid uwsm app -- mpvpaper -o "no-audio loop-file" eDP-1 "$CURRENT_BACKGROUND_LINK" >/dev/null 2>&1 &
  else
    # Handle image files with swaybg
    setsid uwsm app -- swaybg -i "$CURRENT_BACKGROUND_LINK" -m fill >/dev/null 2>&1 &
  fi

  bg_name=$(basename "$background_path")
  notify-send "Background Set" "$bg_name" -t 2000
}

main_menu() {
  choice=$(menu | eval "$rofi_command")
  choice=$(echo "$choice" | xargs)

  if [[ -z "$choice" ]]; then
    exit 0
  fi

  if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
    selected_file="$RANDOM_PIC"
  else
    # Extract filename from the display name (remove [directory] prefix)
    filename=$(echo "$choice" | sed 's/^\[.*\] //')
    selected_file=""

    for dir in "${BACKGROUND_DIRS[@]}"; do
      if [[ -d "$dir" ]]; then
        found=$(find "$dir" -iname "*$filename*" -print -quit 2>/dev/null)
        if [[ -n "$found" ]]; then
          selected_file="$found"
          break
        fi
      fi
    done
  fi

  if [[ -z "$selected_file" ]]; then
    notify-send "Error" "Background not found: $choice" -t 2000
    exit 1
  fi

  set_background "$selected_file"
}

cycle_background() {
  mapfile -d '' -t BACKGROUNDS < <(
    for dir in "${BACKGROUND_DIRS[@]}"; do
      if [[ -d "$dir" ]]; then
        find -L "$dir" -type f \( \
          -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
          -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" \) -print0 2>/dev/null
      fi
    done | sort -z
  )

  TOTAL=${#BACKGROUNDS[@]}
  if [[ $TOTAL -eq 0 ]]; then
    notify-send "No backgrounds found" -t 2000
    pkill -x swaybg
    setsid uwsm app -- swaybg --color '#000000' >/dev/null 2>&1 &
  else
    if [[ -L "$CURRENT_BACKGROUND_LINK" ]]; then
      CURRENT_BACKGROUND=$(readlink "$CURRENT_BACKGROUND_LINK")
    else
      CURRENT_BACKGROUND=""
    fi

    INDEX=-1
    for i in "${!BACKGROUNDS[@]}"; do
      if [[ "${BACKGROUNDS[$i]}" == "$CURRENT_BACKGROUND" ]]; then
        INDEX=$i
        break
      fi
    done

    if [[ $INDEX -eq -1 ]]; then
      NEW_BACKGROUND="${BACKGROUNDS[0]}"
    else
      NEXT_INDEX=$(((INDEX + 1) % TOTAL))
      NEW_BACKGROUND="${BACKGROUNDS[$NEXT_INDEX]}"
    fi

    set_background "$NEW_BACKGROUND"
  fi
}

# Debug: Show all directories being searched
echo "Searching for wallpapers in these directories:"
for dir in "${BACKGROUND_DIRS[@]}"; do
  echo "  - $dir"
done

if [[ "$1" == "--menu" ]] || [[ "$1" == "-m" ]]; then
  main_menu
else
  cycle_background
fi
