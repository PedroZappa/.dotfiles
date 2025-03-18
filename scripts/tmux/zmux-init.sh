#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Load Colors
source ~/.dotfiles/scripts/colors.sh

# Initialization message
echo ${YEL}ZMUX${D}${PRP}: Initializing Dev Env...${D} ${GRN}${D}

# Set Path to Obsidian Vault
if [[ $USER == "zedr0" ]]; then			# DEV-Desk
	OBSIDIAN_VAULT_PATH="$HOME/Documents/Obsidian/ZedroVault"
elif [[ $USER == "passunca" ]]; then	# 42
	OBSIDIAN_VAULT_PATH="$HOME/sgoinfre/Zedro-Vault"
elif [[ $USER == "zedro" ]]; then		# DEV-Mac
	OBSIDIAN_VAULT_PATH="$HOME/Documents/Zedros-Vault"
else
	echo "ZMUX: Unknown user... you shall not PATH! 😅"
fi

export OBSIDIAN_VAULT_PATH

# Command line argument for working directory
if [[ $# -gt 0 ]]; then
    DEV_DIR=$1
else
    DEV_DIR=$HOME  # Default directory if none is provided
fi

# Extract project name from the path
if command -v zoxide &> /dev/null; then
    FULL_DEV_DIR=$(zoxide query "$DEV_DIR") # Use zoxide to get the full path
else
    FULL_DEV_DIR="$DEV_DIR" # Fallback to the provided DEV_DIR if zoxide is not installed
fi
PROJECT_NAME=$(basename "$FULL_DEV_DIR") # Extract the project name

# Session Name variables
SESH1="RC"
SESH2="DEV"

# Create RC session
tmux new-session	-d -s $SESH1
# Create .dotfiles RC window
tmux rename-window	-t RC:1 '.dotfiles'
tmux send-keys		-t RC:1 'cd $HOME/.dotfiles' C-m
tmux send-keys		-t RC:1 'git pull' C-m
tmux send-keys		-t RC:1 'git submodule update --remote --merge' C-m

# Create update window 
tmux new-window		-t RC:2 -n 'update'
tmux send-keys		-t RC:2 'update_env' C-m
# tmux send-keys		-t RC:1 $EDITOR C-m
# Create obsidian RC window
tmux new-window		-t RC:3 -n 'obsidian' -c $OBSIDIAN_VAULT_PATH
tmux send-keys		-t RC:3 'cd '$OBSIDIAN_VAULT_PATH C-m
if command -v eza &> /dev/null; then
	tmux send-keys	-t RC:3 'eza -al' C-m
else
	tmux send-keys		-t RC:3 'll' C-m
fi
if command -v obsidian &> /dev/null; then
	tmux split-window	-t RC:3 -h 
	tmux send-keys		-t RC:3 'cd '$OBSIDIAN_VAULT_PATH C-m
	tmux send-keys		-t RC:3 'git pull' C-m
	tmux send-keys		-t RC:3 'obsidian' C-m
fi

# Create DEV session
tmux new-session	-d -s $SESH2
# Create Working Project window
tmux rename-window	-t DEV:1 "$PROJECT_NAME"
tmux send-keys		-t DEV:1 'cd '$DEV_DIR C-m
# Create Debug window
tmux new-window		-t DEV:2 -n 'GDB'
tmux split-window	-t DEV:2 -h
tmux send-keys		-t DEV:2 'cd '$DEV_DIR C-m
tmux send-keys		-t DEV:2.1 'cd '$DEV_DIR C-m
tmux send-keys		-t DEV:2.1 $EDITOR C-m
tmux send-keys		-t DEV:2.1 ":e .vgdbinit" C-m
tmux send-keys		-t DEV:2.1 ":split .gdbinit" C-m
tmux resize-pane	-L 160
# Create SYNC window
# tmux new-window		-t DEV:3 -n 'DAP'
# tmux send-keys		-t DEV:3 'cd '$DEV_DIR C-m

# Attach to DEV session
tmux attach-session -t DEV:1

echo ${YEL}ZMUX${D}${PRP}: Dev Env ${RED}Destroyed!${D} 💣
