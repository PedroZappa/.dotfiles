#!/bin/bash

# Color Codes note remains the same
# bash -c 'for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done'

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

# Check bash version for associative array support
if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    echo "Error: This script requires bash version 4.0 or higher." >&2
    exit 1
fi

# Enable error handling
# set -euo pipefail

# Get $USER home directory
if [ -n "$SUDO_USER" ]; then
    HOME=$(eval echo ~$SUDO_USER)
else
    HOME=$HOME
fi

# Associative array defining source and target FILES
declare -A FILES=(
    ["$HOME/.dotfiles/ghostty"]="$HOME/.config/ghostty"
    ["$HOME/.dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$HOME/.dotfiles/.zshenv"]="$HOME/.zshenv"
    ["$HOME/.dotfiles/nushell/"]="$HOME/.config/nushell"
    ["$HOME/.dotfiles/.gitconfig"]="$HOME/.gitconfig"
    ["$HOME/.dotfiles/starship.toml"]="$HOME/.config/starship.toml"
    ["$HOME/.dotfiles/.gdbinit"]="$HOME/.gdbinit"
    ["$HOME/.dotfiles/.lnav"]="$HOME/.config/.lnav"
    ["$HOME/.dotfiles/.editorconfig"]="$HOME/.editorconfig"
    ["$HOME/.dotfiles/.vimrc"]="$HOME/.vimrc"
    ["$HOME/.dotfiles/nvim/"]="$HOME/.config/nvim"
    ["$HOME/.dotfiles/.clang-format"]="$HOME/.clang-format"
    ["$HOME/.dotfiles/.tmux.conf.local"]="$HOME/.tmux.conf.local"
    ["$HOME/.dotfiles/kitty/"]="$HOME/.config/kitty"
    ["$HOME/.dotfiles/btop/"]="$HOME/.config/btop"
    ["$HOME/.dotfiles/bat/"]="$HOME/.config/bat"
    ["$HOME/.dotfiles/atuin/"]="$HOME/.config/atuin"
    ["$HOME/.dotfiles/posting/"]="$HOME/.config/posting/"
    ["$HOME/.dotfiles/hypr/"]="$HOME/.config/hypr"
    ["$HOME/.dotfiles/fuzzel.ini"]="$HOME/.config/fuzzel.ini/"
    ["$HOME/.dotfiles/waybar/"]="$HOME/.config/waybar"
    ["$HOME/.dotfiles/eww/"]="$HOME/.config/eww"
    ["$HOME/.dotfiles/spotify-player/"]="$HOME/.config/spotify-player"
    ["$HOME/.dotfiles/.mcphost.json"]="$HOME/.mcphost.json"
)

# Define the backup directory with timestamp
BACKUP_DIR="$HOME/.dotfiles_bak/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Create symlinks to .dotfiles
create_symlink() {
    local SRC="$1"
    local DEST="$2"

    # Check if source exists
    if [ ! -e "$SRC" ]; then
        echo "${RED}Error: Source $SRC does not exist${D}" >&2
        return 1
    fi

    # Backup existing destination if it exists
    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
        local BASENAME=$(basename "$SRC")
        mv "$DEST" "$BACKUP_DIR/${BASENAME}_bak"
        echo "${YEL}Moved existing ${PRP}$SRC ${YEL}to ${PRP}$BACKUP_DIR/${BASENAME}_bak${D}"
    fi

    # Create the symlink
    ln -s "$SRC" "$DEST"
    echo "${YEL}Created symlink from ${GRN}$SRC ${YEL}to ${PRP}$DEST${D}"
}

# Create symlinks with error tracking
ERRORS=0
for SRC in "${!FILES[@]}"; do
    DEST=${FILES[$SRC]}
    if ! create_symlink "$SRC" "$DEST"; then
        ((ERRORS++))
    fi
done

# Final status message
if [ $ERRORS -eq 0 ]; then
    echo "${B}${GRN}󰄬 ${PRP}${USER}${YEL}'s .dotfiles symlinking completed successfully. ${GRN}💻${D}"
else
    echo "${B}${RED}󰄮 ${PRP}${USER}${YEL}'s .dotfiles symlinking completed with $ERRORS errors. ${RED}⚠${D}" >&2
    # exit 1
fi
