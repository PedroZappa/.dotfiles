#!/bin/bash

# Exit the script if any command fails
set -e

# Check if yay is installed
if ! command -v yay > /dev/null 2>&1; then
    echo "yay is not installed. Installing yay..."

    # Install git if it's not already present
    sudo pacman -S --needed git

    # Install base-devel group if any packages are missing
    sudo pacman -S --needed base-devel

    # Create a temporary directory to build yay
    TMPDIR=$(mktemp -d)

    # Clone the yay repository from the AUR
    git clone https://aur.archlinux.org/yay.git "$TMPDIR"

    # Navigate to the cloned directory
    cd "$TMPDIR"

    # Build and install yay (this will prompt for sudo when installing)
    makepkg -si

    # Return to the previous directory and clean up
    cd -
    rm -rf "$TMPDIR"
else
    echo "yay is already installed."
fi

# Now that yay is installed, proceed to install other packages
# Example: Install Google Chrome from the AUR
yay -S ghostty
yay -S zsh
yay -S tmux
yay -S lnav
yay -S btop
yay -S neovim
yay -S ranger
yay -S ripgrep
yay -S clolcat
yay -S cowsay
yay -S fortune-mod
yay -s google-chrome
