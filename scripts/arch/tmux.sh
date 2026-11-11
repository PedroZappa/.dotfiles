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

# Install tpm (Tmux Plugin Manager)
install_tpm() {
	if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
		echo "${YEL}Installing tpm...${D}"
		git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
		echo "${YEL}${B}tpm installation complete.${PRP} 󰩑 ${D}"
	else
		echo "${YEL}tpm already installed. ${PRP} 󰩑 ${D}"
	fi
}

install_tpm
