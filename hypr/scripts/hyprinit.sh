#!/usr/bin/env bash

# &, are used to make the line sof the script non-blocking
#

# Initialize wallpaper Daemon
swww init &
# Set wallpaper
swww img ~/.dotfiles/wallpaper/nixos.png &

# Add network manager applet
nm-applet --indicator &

# Setup waybar
waybar &

dunst &
