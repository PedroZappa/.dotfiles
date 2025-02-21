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
