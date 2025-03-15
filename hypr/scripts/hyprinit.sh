#!/usr/bin/env bash

# &, are used to make the line sof the script non-blocking
#

# Set wallpaper
hyprpaper &
# Add network manager applet
nm-applet --indicator &
# Setup widgets
eww &
# Setup notifications
swaync &

# Send variables to the env
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export WLR_NO_HARDWARE_CURSORS=1
export LIBGL_ALWAYS_SOFTWARE=true
export GALLIUM_DRIVER=llvmpipe

exec Hyprland
