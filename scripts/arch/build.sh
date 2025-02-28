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

# Store the current directory path
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Execute scripts with echo statements
echo "${B}${CYA}Starting zap.sh execution...${D}"
"${SCRIPT_DIR}/zap.sh" || { echo "${B}${RED}Error: zap.sh failed${D}"; exit 1; }

echo "${B}${GRN}Starting tmux.sh execution...${D}"
"${SCRIPT_DIR}/tmux.sh" || { echo "${B}${RED}Error: tmux.sh failed${D}"; exit 1; }

echo "${B}${YEL}Starting sym.sh execution...${D}"
"${SCRIPT_DIR}/sym.sh" || { echo "${B}${RED}Error: sym.sh failed${D}"; exit 1; }

echo "${B}${MAG}Starting yay.sh execution...${D}"
"${SCRIPT_DIR}/yay.sh" || { echo "${B}${RED}Error: yay.sh failed${D}"; exit 1; }

echo "${B}${MAG}Starting chsh.sh execution...${D}"
"${SCRIPT_DIR}/chsh.sh" || { echo "${B}${RED}Error: chsh.sh failed${D}"; exit 1; }

# Remove the colors script
if [ -f "~/colors.sh" ]; then
    rm ~/colors.sh
fi

echo "${B}${BGRN}All scripts executed successfully!${D}"

