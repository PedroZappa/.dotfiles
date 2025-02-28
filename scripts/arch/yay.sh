#!/bin/bash

# Exit the script if any command fails
set -e

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

# Array of packages to install
packages=(
    # Build tools
    "clang"
    "cmake"
    # Terminal biz
    "ghostty"
    "zsh"
    "neovim"
    "tmux"
    "lnav"
    "btop"
    "neovim"
    "ranger"
    "atuin"
    "ripgrep"
    "c-lolcat"
    "cowsay"
    "fortune-mod"
    # C/C++
    "gdb"
    "valgrind"
    # Python
    "uv"
    # Web
    "google-chrome"
    "nodejs"
)

# Loop through the array and install each package
for pkg in "${packages[@]}"; do
    echo "Installing $pkg..."
    yay -S --noconfirm "$pkg"
done

echo "All packages installed successfully!"
