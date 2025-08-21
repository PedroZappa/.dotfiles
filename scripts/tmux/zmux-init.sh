#!/usr/bin/env bash
# set -euo pipefail
# Enhanced ZMUX script with interactive workspace selection

# Load Colors
source ~/.dotfiles/scripts/colors.sh

# Workspace Configuration
# Each workspace has: name, description, creation_function
declare -A WORKSPACES
WORKSPACES[rc]="Resource Center:create_rc_session"
WORKSPACES[dev]="Development Environment:create_dev_session"
WORKSPACES[strudel]="Strudel Development:create_strudel_session"
# Add more workspaces here in the future:
# WORKSPACES[web]="Web Development:create_web_session"
# WORKSPACES[music]="Music Production:create_music_session"

# Default settings
DEFAULT_WORKSPACES=("rc" "dev")
INTERACTIVE=true
ATTACH_SESSION="DEV"

# Help function
show_help() {
    cat << EOF
ZMUX - Zedro's Dev Env Manager

USAGE:
    $0 [OPTIONS] [WORKING_DIRECTORY]

OPTIONS:
    -h, --help              Show this help message
    -w, --workspace LIST    Comma-separated list of workspaces to create
                           Available: ${!WORKSPACES[@]}
    -a, --attach SESSION    Session to attach to after creation (default: DEV)
    -n, --non-interactive   Skip interactive mode
    -l, --list             List available workspaces
    
EXAMPLES:
    $0                                   # Interactive mode
    $0 -w rc,dev,strudel ~/Projects/app  # Create specific workspaces
    $0 -n -w dev ~/code                  # Non-interactive, dev only
    $0 --list                            # Show available workspaces
    
WORKSPACES:
EOF
    for workspace in "${!WORKSPACES[@]}"; do
        IFS=':' read -r desc _ <<< "${WORKSPACES[$workspace]}"
        printf "    %-10s %s\n" "$workspace" "$desc"
    done
}

# List workspaces function
list_workspaces() {
    echo "${YEL}Available Workspaces:${D}"
    for workspace in "${!WORKSPACES[@]}"; do
        IFS=':' read -r desc _ <<< "${WORKSPACES[$workspace]}"
        printf "  ${GRN}%-10s${D} - %s\n" "$workspace" "$desc"
    done
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -w|--workspace)
                if [[ -n $2 && $2 != -* ]]; then
                    IFS=',' read -ra SELECTED_WORKSPACES <<< "$2"
                    INTERACTIVE=false
                    shift 2
                else
                    echo "Error: --workspace requires a value" >&2
                    exit 1
                fi
                ;;
            -a|--attach)
                if [[ -n $2 && $2 != -* ]]; then
                    ATTACH_SESSION="$2"
                    shift 2
                else
                    echo "Error: --attach requires a value" >&2
                    exit 1
                fi
                ;;
            -n|--non-interactive)
                INTERACTIVE=false
                shift
                ;;
            -l|--list)
                list_workspaces
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
            *)
                # This is the working directory
                if [[ -z ${DEV_DIR:-} ]]; then
                    DEV_DIR="$1"
                fi
                shift
                ;;
        esac
    done
}

# Interactive workspace selection
interactive_selection() {
    echo "${YEL}ZMUX${D}${PRP}: Select workspaces to create:${D}"
    echo
    
    local options=()
    local descriptions=()
    
    # Build options array
    for workspace in "${!WORKSPACES[@]}"; do
        IFS=':' read -r desc _ <<< "${WORKSPACES[$workspace]}"
        options+=("$workspace")
        descriptions+=("$desc")
    done
    
    # Add control options
    options+=("all" "default" "done")
    descriptions+=("Select all workspaces" "Select default workspaces (RC + DEV)" "Finish selection")
    
    local selected=()
    local PS3="${GRN}Choose workspaces (multiple selections allowed): ${D}"
    
    while true; do
        echo
        echo "${MAG}Currently selected:${D} ${selected[*]:-none}"
        echo
        
        select opt in "${options[@]}"; do
            case $REPLY in
                "")
                    echo "Invalid selection. Please try again."
                    break
                    ;;
            esac
            
            case $opt in
                "all")
                    selected=($(printf '%s\n' "${!WORKSPACES[@]}" | sort))
                    echo "${GRN}Selected all workspaces.${D}"
                    break
                    ;;
                "default")
                    selected=("${DEFAULT_WORKSPACES[@]}")
                    echo "${GRN}Selected default workspaces.${D}"
                    break
                    ;;
                "done")
                    if [[ ${#selected[@]} -eq 0 ]]; then
                        echo "${RED}No workspaces selected. Please select at least one.${D}"
                        break
                    fi
                    SELECTED_WORKSPACES=("${selected[@]}")
                    return 0
                    ;;
                "")
                    echo "Invalid selection. Please try again."
                    break
                    ;;
                *)
                    # Check if workspace exists
                    if [[ -n ${WORKSPACES[$opt]:-} ]]; then
                        # Check if already selected
                        local already_selected=false
                        for item in "${selected[@]}"; do
                            if [[ $item == $opt ]]; then
                                already_selected=true
                                break
                            fi
                        done
                        
                        if [[ $already_selected == true ]]; then
                            echo "${YEL}$opt is already selected.${D}"
                        else
                            selected+=("$opt")
                            echo "${GRN}Added $opt to selection.${D}"
                        fi
                    else
                        echo "${RED}Invalid workspace: $opt${D}"
                    fi
                    break
                    ;;
            esac
        done
    done
}

# Detect OS function (unchanged)
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "Mac";;
        Linux*)     echo "Linux";;
        CYGWIN*)    echo "Cygwin";;
        MINGW*)     echo "Windows";;
        *)          echo "Unknown";;
    esac
}

# Workspace creation functions
create_rc_session() {
    echo "${GRN}Creating RC (Resource Center) session...${D}"
    
    # Create RC session
    tmux new-session -d -s RC
    
    # Create .dotfiles RC window
    tmux rename-window -t RC:1 '.dotfiles'
    tmux send-keys -t RC:1 'cd $HOME/.dotfiles' C-m
    tmux send-keys -t RC:1 'git pull' C-m
    tmux send-keys -t RC:1 'git submodule update --remote --merge' C-m
    
    # Create obsidian RC window
    tmux new-window -t RC:2 -n 'obsidian' -c "$OBSIDIAN_VAULT_PATH"
    tmux send-keys -t RC:2 "cd '$OBSIDIAN_VAULT_PATH'" C-m
    if command -v eza &> /dev/null; then
        tmux send-keys -t RC:2 'eza -al' C-m
    else
        tmux send-keys -t RC:2 'll' C-m
    fi
    if command -v obsidian &> /dev/null; then
        tmux split-window -t RC:2 -v 
        tmux send-keys -t RC:2 "cd '$OBSIDIAN_VAULT_PATH'" C-m
        tmux send-keys -t RC:2 'git pull' C-m
        tmux send-keys -t RC:2 'obsidian' C-m
    fi
    
    # Create Spotify window
    tmux new-window -t RC:3 -n 'Spotify'
    tmux send-keys -t RC:3 'spotify_player' C-m
    
    # Create update window 
    tmux new-window -t RC:4 -n 'update'
    tmux send-keys -t RC:4 'update_env' C-m
}

create_dev_session() {
    echo "${GRN}Creating DEV (Development) session...${D}"
    
    # Create DEV session
    tmux new-session -d -s DEV
    
    # Create Working Project window
    tmux rename-window -t DEV:1 "$PROJECT_NAME"
    tmux send-keys -t DEV:1 "cd '$DEV_DIR'" C-m
    
    # Create Aux window
    tmux new-window -t DEV:2 -n '...'
}

create_strudel_session() {
    echo "${GRN}Creating Strudel (Audio Programming) session...${D}"
    
    # Create Strudel session
    tmux new-session -d -s STRUDEL
    
    # Main Strudel development window
    STRUDEL_ZEDRO_PATH="$HOME/C0D3/AUDIO/strudel.zedro"
    WINDOW_NAME='$(basename "$STRUDEL_LSP_PATH")'
    tmux rename-window -t STRUDEL:1 '${WINDOW_NAME}'
    if [[ -d "${STRUDEL_ZEDRO_PATH}" ]]; then
        tmux send-keys -t STRUDEL:1 'cd ${STRUDEL_ZEDRO_PATH}' C-m
    else
        tmux send-keys -t STRUDEL:1 "cd '$DEV_DIR'" C-m
    fi
    tmux send-keys -t STRUDEL:1 'clear' C-m
    
    # LSP Development window (since you work on Strudel LSP)
    STRUDEL_LSP_PATH="$HOME/C0D3/AUDIO/strudel-lsp-server"
    WINDOW_NAME='$(basename "$STRUDEL_LSP_PATH")'
    tmux new-window -t STRUDEL:2 -n '${WINDOW_NAME}'
    if [[ -d "${STRUDEL_LSP_PATH}" ]]; then
        tmux send-keys -t STRUDEL:2 'cd ${STRUDEL_LSP_PATH}' C-m
    else
        tmux send-keys -t STRUDEL:2 "cd '$DEV_DIR'" C-m
    fi
    tmux send-keys -t STRUDEL:2 'clear' C-m
}

# Example template for adding new workspaces
# create_web_session() {
#     echo "${GRN}Creating Web Development session...${D}"
#     tmux new-session -d -s WEB
#     tmux rename-window -t WEB:1 'frontend'
#     tmux send-keys -t WEB:1 "cd '$DEV_DIR'" C-m
#     tmux new-window -t WEB:2 -n 'backend'
#     tmux send-keys -t WEB:2 "cd '$DEV_DIR'" C-m
#     # Add more web-specific setup here
# }

# Main execution function
main() {
    # Initialize
    echo "${YEL}ZMUX${D}${PRP}: Initializing Dev Env...${D} ${GRN}${D}"
    
    # System detection
    OS=$(detect_os)
    ARCH=$(uname -m)
    echo "Detected OS: ${MAG}${OS}${D}"
    echo "Detected architecture: ${MAG}${ARCH}${D}"
    
    # Set OBSIDIAN
    if [[ $ARCH == "x86_64" ]]; then
        OBSIDIAN_VAULT_PATH="$HOME/Documents/Zedros-Vault"
        OBSIDIAN_LYRICS_VAULT_PATH="$HOME/Documents/lyrics.vault"
    elif [[ $OS == "Mac" ]]; then
        OBSIDIAN_VAULT_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Zedros-Vault"
        OBSIDIAN_LYRICS_VAULT_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/lyrics.vault"
    else
        echo "ZMUX: Unknown architecture ($ARCH)... you shall not PATH! 😅"
    fi
    
    export OBSIDIAN_VAULT_PATH
    export OBSIDIAN_LYRICS_VAULT_PATH
    
    # Set working directory
    if [[ -z ${DEV_DIR:-} ]]; then
        DEV_DIR=$HOME
    fi
    
    # Handle zoxide/directory resolution
    if command -v zoxide &> /dev/null; then
        FULL_DEV_DIR=$(zoxide query "$DEV_DIR")
    else
        FULL_DEV_DIR="$DEV_DIR"
    fi
    PROJECT_NAME=$(basename "$FULL_DEV_DIR")
    
    # Interactive or non-interactive selection
    if [[ $INTERACTIVE == true && ${#SELECTED_WORKSPACES[@]} -eq 0 ]]; then
        interactive_selection
    elif [[ ${#SELECTED_WORKSPACES[@]} -eq 0 ]]; then
        # Use default workspaces if none specified
        SELECTED_WORKSPACES=("${DEFAULT_WORKSPACES[@]}")
    fi
    
    echo
    echo "${YEL}Creating selected workspaces:${D} ${SELECTED_WORKSPACES[*]}"
    echo
    
    # Create selected workspaces
    for workspace in "${SELECTED_WORKSPACES[@]}"; do
        if [[ -n ${WORKSPACES[$workspace]:-} ]]; then
            IFS=':' read -r _ func_name <<< "${WORKSPACES[$workspace]}"
            if command -v "$func_name" >/dev/null 2>&1; then
                "$func_name"
            else
                echo "${RED}Error: Function $func_name not found for workspace $workspace${D}"
            fi
        else
            echo "${RED}Error: Unknown workspace: $workspace${D}"
        fi
    done
    
    echo
    echo "${GRN}All selected workspaces created successfully!${D}"
    echo
    
    # Attach to the specified session
    if tmux has-session -t "$ATTACH_SESSION" 2>/dev/null; then
        echo "${GRN}Attaching to $ATTACH_SESSION session...${D}"
        tmux attach-session -t "$ATTACH_SESSION:1"
    else
        echo "${YEL}Session $ATTACH_SESSION not found. Available sessions:${D}"
        tmux list-sessions
        echo
        echo "${YEL}Please attach manually using: tmux attach-session -t <session-name>${D}"
    fi
    
    echo "${YEL}ZMUX${D}${PRP}: Dev Env ${RED}Destroyed!${D} 💣"
}

# Parse command line arguments
parse_arguments "$@"

# Run main function
main

