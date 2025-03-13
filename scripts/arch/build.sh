#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Color Codes
# Run the following command to get list of available colors
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

# Save the current working directory
ORIG_DIR="$(pwd)"
# Change to .dotfiles directory if not already there
if [ "$(basename "$ORIG_DIR")" != ".dotfiles" ]; then
    cd ~/.dotfiles || { echo "Error: Failed to cd into ~/.dotfiles"; exit 1; }
fi

# Execute command
echo "${B}${CYA}Getting git submodules...${D}"
git submodule update --init --recursive --progress || { 
    echo "${B}${RED}Error: git submodules failed${D}"; 
    cd "$ORIG_DIR" && exit 1
}

# Return to the original directory
cd "$ORIG_DIR"
# Store the current directory path
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

echo "${B}${CYA}Starting zap.sh execution...${D}"
"${SCRIPT_DIR}/zap.sh" || { echo "${B}${RED}Error: zap.sh failed${D}"; exit 1; }

echo "${B}${GRN}Starting tmux.sh execution...${D}"
"${SCRIPT_DIR}/tmux.sh" || { echo "${B}${RED}Error: tmux.sh failed${D}"; exit 1; }

echo "${B}${YEL}Starting sym.sh execution...${D}"
"${SCRIPT_DIR}/sym.sh" || { echo "${B}${RED}Error: sym.sh failed${D}"; exit 1; }

echo "${B}${MAG}Starting yay.sh execution...${D}"
"${SCRIPT_DIR}/yay.sh" || { echo "${B}${RED}Error: yay.sh failed${D}"; exit 1; }

echo "${B}${CYA}Checking if GDM is installed...${D}"
if pacman -Qs gdm > /dev/null; then
    echo "${B}${GRN}GDM found! Starting gdm.sh execution...${D}"
    "${SCRIPT_DIR}/gdm.sh" || { echo "${B}${RED}Error: gdm.sh failed${D}"; exit 1; }
else
    echo "${B}${YEL}GDM not installed. Skipping gdm.sh.${D}"
fi
echo "${B}${MAG}Starting chsh.sh execution...${D}"
"${SCRIPT_DIR}/chsh.sh" || { echo "${B}${RED}Error: chsh.sh failed${D}"; exit 1; }

# Remove the colors script
if [ -f "~/colors.sh" ]; then
    rm ~/colors.sh
fi

echo "${B}${BGRN}All scripts executed successfully!${D}"

