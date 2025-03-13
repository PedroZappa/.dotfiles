#!/usr/bin/env bash

# Load Colors
if [ -d ~/.dotfiles ]; then
    source ~/.dotfiles/scripts/colors.sh
else
    if [ ! -f ~/colors.sh ]; then
        echo -e "${YEL}Colors script not found, downloading: ${D}"
        wget https://raw.githubusercontent.com/PedroZappa/.dotfiles.min/refs/heads/main/scripts/colors.sh
    fi
    source ./colors.sh
fi

echo "${GRN}${B}Create a custom dconf profile${D}"
sudo mkdir -p /etc/dconf/db/gdm.d/
echo '[org/gnome/desktop/screensaver]' | sudo tee /etc/dconf/db/gdm.d/z-screensaver > /dev/null
echo 'picture-uri="file:///$HOME/.dotfiles/wallpapers/bbln_black.jpg"' | sudo tee -a /etc/dconf/db/gdm.d/z-screensaver > /dev/null

echo "${GRN}${B}Update dconf database${D}"
sudo dconf update
