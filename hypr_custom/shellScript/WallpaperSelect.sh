#!/bin/bash

# Cycles through the background images available with menu selection

BACKGROUNDS_DIR="$HOME/.config/omarchy/current/theme/backgrounds/"
CURRENT_BACKGROUND_LINK="$HOME/.config/omarchy/current/background"

# WALLPAPERS PATH
terminal=ghostty
SCRIPTSDIR="$HOME/dotfiles/hypr_custom/shellScript/"
wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

# Directory for notifications
iDIR="$HOME/.config/swaync/images"
iDIRi="$HOME/.config/swaync/icons"

# swww transition config (if using swww instead of swaybg)
FPS=60
TYPE="any"
DURATION=2
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Check if package bc exists (for icon sizing)
if ! command -v bc &>/dev/null; then
  notify-send -i "$iDIR/error.png" "bc missing" "Install package bc first"
  exit 1
fi

# Variables
rofi_theme="$HOME/.config/rofi/config-wallpaper.rasi"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' 2>/dev/null || echo "")

# Ensure focused_monitor is detected
if [[ -z "$focused_monitor" ]]; then
  # Fallback to first monitor if hyprctl not available
  focused_monitor=$(swaymsg -t get_outputs | jq -r '.[0].name' 2>/dev/null || echo "")
fi

# Monitor details for icon sizing
if [[ -n "$focused_monitor" ]]; then
  scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale' 2>/dev/null || echo "1")
  monitor_height=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .height' 2>/dev/null || echo "1080")

  icon_size=$(echo "scale=1; ($monitor_height * 3) / ($scale_factor * 150)" | bc)
  adjusted_icon_size=$(echo "$icon_size" | awk '{if ($1 < 15) $1 = 20; if ($1 > 25) $1 = 25; print $1}')
  rofi_override="element-icon{size:${adjusted_icon_size}%;}"
else
  rofi_override="element-icon{size:20%;}"
fi

# Retrieve wallpapers
mapfile -d '' PICS < <(find -L "${BACKGROUNDS_DIR}" -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
  -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o \
  -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) -print0 2>/dev/null)

# If no wallpapers found, fall back to original cycling behavior
if [[ ${#PICS[@]} -eq 0 ]]; then
  notify-send "No background was found for theme" -t 2000
  pkill -x swaybg
  setsid uwsm app -- swaybg --color '#000000' >/dev/null 2>&1 &
  exit 0
fi

RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME=". random"

# Rofi command
rofi_command="rofi -i -show -dmenu -config $rofi_theme -theme-str \"$rofi_override\""

# Menu function to display wallpapers
menu() {
  IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))

  printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"

  for pic_path in "${sorted_options[@]}"; do
    pic_name=$(basename "$pic_path")
    if [[ "$pic_name" =~ \.gif$ ]]; then
      cache_gif_image="$HOME/.cache/gif_preview/${pic_name}.png"
      if [[ ! -f "$cache_gif_image" ]]; then
        mkdir -p "$HOME/.cache/gif_preview"
        magick "$pic_path[0]" -resize 1920x1080 "$cache_gif_image" 2>/dev/null ||
          cp "$pic_path" "$cache_gif_image" 2>/dev/null
      fi
      printf "%s\x00icon\x1f%s\n" "$pic_name" "$cache_gif_image"
    elif [[ "$pic_name" =~ \.(mp4|mkv|mov|webm|MP4|MKV|MOV|WEBM)$ ]]; then
      cache_preview_image="$HOME/.cache/video_preview/${pic_name}.png"
      if [[ ! -f "$cache_preview_image" ]]; then
        mkdir -p "$HOME/.cache/video_preview"
        ffmpeg -v error -y -i "$pic_path" -ss 00:00:01.000 -vframes 1 "$cache_preview_image" 2>/dev/null ||
          cp "$pic_path" "$cache_preview_image" 2>/dev/null
      fi
      printf "%s\x00icon\x1f%s\n" "$pic_name" "$cache_preview_image"
    else
      printf "%s\x00icon\x1f%s\n" "$(echo "$pic_name" | cut -d. -f1)" "$pic_path"
    fi
  done
}

# Set background function (using your original swaybg approach)
set_background() {
  local background_path="$1"

  # Set new background symlink
  ln -nsf "$background_path" "$CURRENT_BACKGROUND_LINK"

  # Relaunch swaybg
  pkill -x swaybg
  setsid uwsm app -- swaybg -i "$CURRENT_BACKGROUND_LINK" -m fill >/dev/null 2>&1 &

  # Optional: Send notification
  bg_name=$(basename "$background_path")
  notify-send "Background Set" "$bg_name" -t 2000
}

# Main function with menu selection
main_menu() {
  # Check if rofi is available
  if ! command -v rofi &>/dev/null; then
    echo "rofi not found, falling back to cycle mode"
    cycle_background
    return
  fi

  choice=$(menu | eval "$rofi_command")
  choice=$(echo "$choice" | xargs)
  RANDOM_PIC_NAME=$(echo "$RANDOM_PIC_NAME" | xargs)

  if [[ -z "$choice" ]]; then
    echo "No choice selected. Exiting."
    exit 0
  fi

  # Handle random selection correctly
  if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
    selected_file="$RANDOM_PIC"
  else
    # Search for the selected file
    choice_basename=$(basename "$choice" | sed 's/\(.*\)\.[^.]*$/\1/')
    selected_file=$(find "$BACKGROUNDS_DIR" -iname "$choice_basename.*" -print -quit 2>/dev/null)

    if [[ -z "$selected_file" ]]; then
      # If not found by basename, try exact match
      selected_file=$(find "$BACKGROUNDS_DIR" -iname "$choice" -print -quit 2>/dev/null)
    fi
  fi

  if [[ -z "$selected_file" ]]; then
    echo "File not found. Selected choice: $choice"
    notify-send "Error" "Background file not found: $choice" -t 2000
    exit 1
  fi

  set_background "$selected_file"
}

# Original cycle function (fallback)
cycle_background() {
  mapfile -d '' -t BACKGROUNDS < <(find "$BACKGROUNDS_DIR" -type f -print0 | sort -z)
  TOTAL=${#BACKGROUNDS[@]}

  if [[ $TOTAL -eq 0 ]]; then
    notify-send "No background was found for theme" -t 2000
    pkill -x swaybg
    setsid uwsm app -- swaybg --color '#000000' >/dev/null 2>&1 &
  else
    # Get current background from symlink
    if [[ -L "$CURRENT_BACKGROUND_LINK" ]]; then
      CURRENT_BACKGROUND=$(readlink "$CURRENT_BACKGROUND_LINK")
    else
      # Default to first background if no symlink exists
      CURRENT_BACKGROUND=""
    fi

    # Find current background index
    INDEX=-1
    for i in "${!BACKGROUNDS[@]}"; do
      if [[ "${BACKGROUNDS[$i]}" == "$CURRENT_BACKGROUND" ]]; then
        INDEX=$i
        break
      fi
    done

    # Get next background (wrap around)
    if [[ $INDEX -eq -1 ]]; then
      # Use the first background when no match was found
      NEW_BACKGROUND="${BACKGROUNDS[0]}"
    else
      NEXT_INDEX=$(((INDEX + 1) % TOTAL))
      NEW_BACKGROUND="${BACKGROUNDS[$NEXT_INDEX]}"
    fi

    set_background "$NEW_BACKGROUND"
  fi
}

# Check if we should show menu or cycle
if [[ "$1" == "--menu" ]] || [[ "$1" == "-m" ]]; then
  main_menu
else
  cycle_background
fi
