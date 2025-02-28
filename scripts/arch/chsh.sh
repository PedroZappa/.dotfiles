#!/bin/bash
# Color Codes
# Run the following command to get list of available colors
# bash -c 'for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done'

# Load Colors
if [ -d ~/.dotfiles ]; then
    source ~/.dotfiles/scripts/colors.sh
else
    if [ ! -f ~/colors.sh ]; then
        echo -e "Colors script not found, downloading:"
        wget https://raw.githubusercontent.com/PedroZappa/.dotfiles.min/refs/heads/main/scripts/colors.sh
    fi
    source ./colors.sh
fi

# Check if zsh is installed by looking in /etc/shells
ZSH_PATH=$(grep -E '^/.*zsh$' /etc/shells | head -n 1)

if [ -z "$ZSH_PATH" ]; then
    echo "${RED}zsh not found in /etc/shells${D}"
    echo "${YEL}Please install zsh first${D}"
    exit 1
fi

echo "${GRN}Found zsh at:${D} $ZSH_PATH"

# Change the default shell
echo "${MAG}Changing system default shell to zsh..."
if chsh -s "$ZSH_PATH"; then
    echo "${GRN}Successfully changed default shell to zsh${D}"
else
    echo "${RED}Failed to change shell${D}"
    exit 1
fi

# Ask user about reboot
while true; do
    read -p "${MAG}Would you like to reboot now? (y/n): ${D}" answer
    case $answer in
        [Yy]*)
            echo "${MAG}Rebooting system...${D}"
            reboot
            break
            ;;
        [Nn]*)
            echo "${GRN}Shell changed. Please log out and back in for changes to take effect.${D}"
            break
            ;;
        *)
            echo "${YEL}Please answer y or n${D}"
            ;;
    esac
done
