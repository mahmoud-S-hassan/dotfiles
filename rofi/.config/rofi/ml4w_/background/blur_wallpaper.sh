#!/usr/bin/env bash

# Base folder
base="/home/abo-salah/.config/rofi/ml4w_/background"
mkdir -p "$base/wallpaper" "$base/wallpaper-generated"

# Files
cachefile="$base/current_wallpaper"
blurredwallpaper="$base/blurred_wallpaper.png"
rasifile="$base/current_wallpaper.rasi"
defaultwallpaper="$base/wallpaper/a_road_with_lightning_bolts_in_the_sky.png"
blur="50x30" # you can change this

# Pick wallpaper (argument > cached > default)
if [ -n "$1" ]; then
  wallpaper="$1"
elif [ -f "$cachefile" ]; then
  wallpaper=$(cat "$cachefile")
else
  wallpaper="$defaultwallpaper"
fi

echo "$wallpaper" >"$cachefile"
wallpaperfilename=$(basename "$wallpaper")

# Generate blurred wallpaper
if [ ! -f "$base/wallpaper-generated/blur-$blur-$wallpaperfilename.png" ]; then
  echo "Generating blurred version of $wallpaper with blur $blur"
  magick "$wallpaper" -resize 75% "$blurredwallpaper"
  if [ ! "$blur" == "0x0" ]; then
    magick "$blurredwallpaper" -blur "$blur" "$blurredwallpaper"
    cp "$blurredwallpaper" "$base/wallpaper-generated/blur-$blur-$wallpaperfilename.png"
  fi
else
  echo "Using cached blurred wallpaper"
  cp "$base/wallpaper-generated/blur-$blur-$wallpaperfilename.png" "$blurredwallpaper"
fi

# Create rofi rasi file
echo "* { current-image: url(\"$blurredwallpaper\", height); }" >"$rasifile"

echo "✅ Blurred wallpaper saved at $blurredwallpaper"
echo "✅ Rofi rasi file generated at $rasifile"
