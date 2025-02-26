#!/bin/bash
# Color Codes
# Run the following command to get list of available colors
# bash -c 'for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done'

B=$(tput bold)
BLA=$(tput setaf 0)
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YEL=$(tput setaf 3)
BLU=$(tput setaf 4)
MAG=$(tput setaf 5)
CYA=$(tput setaf 6)
WHI=$(tput setaf 7)
GRE=$(tput setaf 8)
PRP=$(tput setaf 99)
BRED=$(tput setaf 9)
BGRN=$(tput setaf 10)
BYEL=$(tput setaf 11)
BBLU=$(tput setaf 12)
BMAG=$(tput setaf 13)
BCYA=$(tput setaf 14)
BWHI=$(tput setaf 15)
D=$(tput sgr0)
BEL=$(tput bel)

# Check bash version for associative array support
if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    echo "Error: This script requires bash version 4.0 or higher." >&2
    exit 1
fi

# Associative array defining source and target FILES
declare -A FILES
FILES=(
    ["$HOME/.dotfiles/nixos"]="$HOME/etc/"
    ["$HOME/.dotfiles/ghostty"]="$HOME/.config/"
    ["$HOME/.dotfiles/.profile"]="$HOME/.profile"
    ["$HOME/.dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$HOME/.dotfiles/.zshenv"]="$HOME/.zshenv"
    # ["$HOME/.dotfiles/.bashrc"]="$HOME/.bashrc"
    ["$HOME/.dotfiles/nushell"]="$HOME/.config"
    ["$HOME/.dotfiles/.gitconfig"]="$HOME/.gitconfig"
    ["$HOME/.dotfiles/starship.toml"]="$HOME/.config/starship.toml"
    ["$HOME/.dotfiles/.gitconfig"]="$HOME/.gitconfig"
    ["$HOME/.dotfiles/.gdbinit"]="$HOME/.gdbinit"
    ["$HOME/.dotfiles/.lnav"]="$HOME/.config"
    ["$HOME/.dotfiles/.editorconfig"]="$HOME/.editorconfig"
    ["$HOME/.dotfiles/.vimrc"]="$HOME/.vimrc"
    ["$HOME/.dotfiles/nvim"]="$HOME/.config"
    ["$HOME/.dotfiles/.clang-format"]="$HOME/.clang-format"
    ["$HOME/.dotfiles/.tmux.conf.local"]="$HOME/.tmux.conf.local"
    ["$HOME/.dotfiles/kitty/"]="$HOME/.config"
    ["$HOME/.dotfiles/ghostty/"]="$HOME/.config"
    ["$HOME/.dotfiles/btop/"]="$HOME/.config"
    ["$HOME/.dotfiles/bat/"]="$HOME/.config"
    ["$HOME/.dotfiles/atuin/"]="$HOME/.config"
    ["$HOME/.dotfiles/posting/"]="$HOME/.config"
    ["$HOME/.dotfiles/hypr"]="$HOME/.config"
)

# Define the backup directory and create it if it doesn't exist
BACKUP_DIR="$HOME/.dotfiles_bak"
mkdir -p "$BACKUP_DIR"

# Create symlinks to .dotfiles
create_symlink() {
    local SRC=$1
    local DEST=$2

    # Check if the destination file/directory exists
    if [ -e "$DEST" ]; then
        # Extract the basename of DEST and move existing file/directory to backup
        local BASENAME=$(basename "$DEST")
        mv "$DEST" "$BACKUP_DIR/${BASENAME}_bak"
        echo "${YEL}Moved existing ${PRP}$DEST ${YEL}to ${PRP}$BACKUP_DIR/${BASENAME}_bak${D}"
    fi
    # Create the parent directory if it doesn't exist
    mkdir -p "$(dirname "$DEST")"
    # Create the symlink
    ln -s "$SRC" "$DEST"
    echo "${YEL}Created symlink from ${GRN}$SRC ${YEL}to ${PRP}$DEST${D}"
}

# Create symlinks
for SRC in "${!FILES[@]}"; do
    DEST=${FILES[$SRC]}
    create_symlink "$SRC" "$DEST"
done

echo "${B}${GRN}󰄬 ${PRP}${USER}${YEL}'s .dotfiles symlinking complete. ${GRN}💻${D}"


