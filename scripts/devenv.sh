#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

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

### Dev Environment Setup
# Sources:
# Brew without sudo
# https://nelsonaloysio.medium.com/installing-homebrew-without-sudo-5e708a929522

# Check bash version for associative array support
if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    echo "Error: This script requires bash version 4.0 or higher." >&2
    exit 1
fi

# Ensure git, curl and wget are installed
command_exists() {
    if [ ! command -v "$1" &> /dev/null ]; then
        echo "${RED}Error: You do not have ${command} installed, Exiting...${D}" >&2
        exit 1
	fi
}

# Express installation
# Check for --express argument
EXPRESS_INSTALL=false
if [[ $# -gt 0 && "$1" == "--express" ]]; then
    EXPRESS_INSTALL=true
fi

echo "${B}${YEL}Installing ${PRP}$USER${YEL}'s dev environment...${D}${GRN}💻${D}"
echo "${B}${RED}Do you want to express install?${D} ${B}(y/n)${D}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
	EXPRESS_INSTALL=true
	echo "${B}${YEL}Express installing...${D} 🚀"
else
	echo "${YEL}Express installation skipped. ${D}"
fi

# Install System Packages
declare -A SYSTEM_PACKAGES
SYSTEM_PACKAGES=(
	["build-essential"]="Build Essential"
	["libreadline-dev"]="Libreadline Dev"
	["cmake"]="cmake"
	["curl"]="Curl"
	["wget"]="Wget"
	["git"]="Git"
	["vim"]="Vim"
	["zsh"]="Zsh"
	["tmux"]="Tmux"
)

# Install System Packages
install_system_packages() {
	if ! sudo -n true 2>/dev/null; then
        echo "${RED}Error: You do not have sudo privileges. Exiting...${D}" >&2
        exit 1
    fi
    for package in "${!SYSTEM_PACKAGES[@]}"; do
        if ! command_exists "$package"; then
            echo "${YEL}Installing system package ${GRN}${B}${SYSTEM_PACKAGES[$package]}${D}${YEL}...${D}"
            sudo apt-get install -y "$package"
        else
            echo "${GRN}${SYSTEM_PACKAGES[$package]}${YEL} is already installed.${D}"
        fi
    done
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "${PRP}${B}Do you want to install the required ${GRN}${B}System Packages${D}? ${YEL}(y/n)${D}"
    read -r install_sys_packages
    if [[ "$install_sys_packages" =~ ^[Yy]$ ]]; then
        install_system_packages
    else
        echo "${YEL}Skipping system package installation.${D}"
    fi
else
    install_system_packages
fi

# Associative array defining source and target FILES
declare -A FILES
FILES=(
    ["$HOME/.dotfiles/ghostty"]="$HOME/.config/"
    ["$HOME/.dotfiles/.profile"]="$HOME/.profile"
    ["$HOME/.dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$HOME/.dotfiles/.zshenv"]="$HOME/.zshenv"
    ["$HOME/.dotfiles/.bashrc"]="$HOME/.bashrc"
    ["$HOME/.dotfiles/nushell"]="$HOME/.config/"
	["$HOME/.dotfiles/starship.toml"]="$HOME/.config/starship.toml"
    ["$HOME/.dotfiles/.gitconfig"]="$HOME/.gitconfig"
    ["$HOME/.dotfiles/.gdbinit"]="$HOME/.gdbinit"
    ["$HOME/.dotfiles/.editorconfig"]="$HOME/.editorconfig"
    ["$HOME/.dotfiles/.vimrc"]="$HOME/.vimrc"
    ["$HOME/.dotfiles/nvim"]="$HOME/.config/"
    ["$HOME/.dotfiles/.clang-format"]="$HOME/.clang-format"
    ["$HOME/.dotfiles/.tmux.conf.local"]="$HOME/.tmux.conf.local"
    # ["$HOME/.dotfiles/kitty/"]="$HOME/.config/"
    ["$HOME/.dotfiles/btop/"]="$HOME/.config/"
    ["$HOME/.dotfiles/atuin/"]="$HOME/.config/"
    ["$HOME/.dotfiles/posting/"]="$HOME/.config/"
    # ["$HOME/.dotfiles/hypr"]="$HOME/.config/"
)

ZEDRO_DOTFILES_SSH_URL="git@github.com:PedroZappa/zedro-dotfiles.git "

# Prompt to choose between Zedro's dotfiles or custom folder
choose_dotfiles() {
    echo "${B}${PRP}Do you want to clone ${YEL}Zedro${PRP}'s .dotfiles repository or use a custom folder?${D}"
    echo "${YEL}(1) Clone Zedro's .dotfiles${D}"
    echo "${YEL}(2) Use custom folder${D}"
    read -r dotfiles_choice

    case $dotfiles_choice in
        1)
            if [[ ! -d "$HOME/.dotfiles" ]]; then
                clone_dotfiles "$ZEDRO_DOTFILES_SSH_URL"
            else
                cd "$HOME/.dotfiles"
                git pull
                echo "${YEL}.dotfiles repository up to date. ${PRP}󰩑 ${D}"
            fi
            ;;
        2)
            echo "${YEL}Please provide the path to your custom .dotfiles folder:${D}"
            read -r custom_dotfiles_path
            if [[ -z "$custom_dotfiles_path" ]]; then
				echo "${RED}Error: No SSH link provided. Exiting...${D}" >&2
                exit 1
            fi
			clone_dotfiles "$custom_dotfiles_path"
            ;;
        *)
            echo "${RED}Invalid option selected. Exiting...${D}" >&2
            exit 1
            ;;
    esac
}

# Clone .dotfiles
clone_dotfiles() {
	if [[ ! -d "$HOME/.dotfiles" ]]; then
		cd "$HOME"
		git clone "$1" ./.dotfiles
		echo "${YEL}.dotfiles repository successfully cloned. ${PRP}󰩑 ${D}"
	fi
}


if [[ "$EXPRESS_INSTALL" == false ]]; then
    echo "${B}${PRP}Do you want to clone a ${RED}.dotfiles${PRP} repository? ${YEL}(y/n)${D}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
		if [ ! -d "$HOME/.dotfiles" ]; then
			choose_dotfiles
		else
			cd "$HOME/.dotfiles"
			git pull
			echo "${YEL}.dotfiles repository up to date. ${PRP}󰩑 ${D}"
		fi
	else
		echo "${YEL}.dotfiles cloning skipped.${D}"
    fi
else
	if [ ! -d "$HOME/.dotfiles" ]; then
		choose_dotfiles
	else
		cd "$HOME/.dotfiles"
		git pull
		echo "${YEL}.dotfiles repository up to date. ${PRP}󰩑 ${D}"
	fi
fi

# Create symlinks to .dotfiles
create_symlink() {
    local SRC=$1
    local DEST=$2

    # Check if the destination file/directory exists
    if [ -e "$DEST" ]; then
        # If it exists, move it to a backup
        mv "$DEST" "${DEST}_bak"
        echo "${YEL}Moved existing ${PRP}$DEST ${YEL}to ${PRP}${DEST}_bak${D}"
    fi
    # Create the parent directory if it doesn't exist
    mkdir -p "$(dirname "$DEST")"
    # Create the symlink
    ln -s "$SRC" "$DEST"
    echo "${YEL}Created symlink from ${GRN}$SRC ${YEL}to ${PRP}$DEST${D}"
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "${PRP}${B}Do you want to create symlinks to ${RED}.dotfiles${PRP} repository? ${YEL}(y/n)${D}"
	read -r create_symlinks
	if [[ "$create_symlinks" =~ ^[Yy]$ ]]; then
		for SRC in "${!FILES[@]}"; do
			DEST=${FILES[$SRC]}
			create_symlink "$SRC" "$DEST"
		done
	else
		echo "${YEL}Skipping ${GRN}symlink ${YEL}creation.${D}"
	fi
else
	for SRC in "${!FILES[@]}"; do
		DEST=${FILES[$SRC]}
		create_symlink "$SRC" "$DEST"
	done
fi

# Install zap, zsh's Package Manager
ZAP_DIR="$HOME/.local/share/zap"

install_zap() {
	echo "${YEL}Installing ${B}${RED}zap${D}: ${YEL}zsh's Package Manager...${D}"
	zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
	echo "zap installation complete. 🤙"
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "${PRP}${B}Do you want to install ${RED}zap, ${PRP}zsh's Package Manager? ${YEL}(y/n)${D}"
	read -r install_zap
	if [[ "$install_zap" =~ ^[Yy]$ ]]; then
		if [[ ! -d "$ZAP_DIR" ]]; then
			install_zap
		else
			echo "${YEL}zap already installed. 🤙${D}"
		fi
	else
		echo "${YEL}Skipping ${RED}zap, ${YEL}installation.${D}"
	fi
else
	install_zap
fi

# Install vim-plug
install_vim_plug() {
	echo "${YEL}Installing ${PRP}vim-plug${YEL}...${D}"
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	# Create vim directories
	mkdir -p ~/.vim ~/.vim/autoload ~/.vim/backup ~/.vim/colors ~/.vim/plugged
	# Install color scheme
	cd ~/.vim/colors
	curl -o molokai.vim https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
	curl -o dracula.vim https://raw.githubusercontent.com/dracula/vim/210e0961b9bd765b5b46a84d0631271ee8e6af64/colors/dracula.vim
	echo "${PRP}vim-plug ${YEL}installation complete. 🤙${D}"
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "${PRP}${B}Do you want to install ${RED}vim-plug ${PRP}vim's package manager? ${YEL}(y/n)${D}"
	read -r install_vim_plug
	if [[ "$install_vim_plug" =~ ^[Yy]$ ]]; then
		install_vim_plug
	else
		echo "${YEL}Skipping ${RED}vim-plug ${YEL}installation.${D}"
	fi
else
	install_vim_plug
fi

# Install oh-my-tmux
install_oh_my_tmux() {
	if [[ ! -d "$HOME/.tmux" || ! -L "$HOME/.tmux.conf" ]]; then
		echo "${YEL}Installing oh-my-tmux...${D}"
		cd "$HOME"
		git clone https://github.com/gpakosz/.tmux.git
		ln -s -f .tmux/.tmux.conf
		echo "${YEL}${B}oh-my-tmux installation complete.${PRP} 󰩑 ${D}"
	else
		echo "${YEL}oh-my-tmux already installed. ${PRP} 󰩑 ${D}"
	fi
}

echo "${PRP}${B}Do you want to install ${RED}oh-my-tmux${PRP} config? ${YEL}(y/n)${D}"
read -r install_tmux
if [[ "$install_tmux" =~ ^[Yy]$ ]]; then
    install_oh_my_tmux
else
	echo "${YEL}Skipping ${RED}oh-my-tmux ${YEL}installation.${D}"
fi

if ! command_exists git; then
    echo "Error: git is not installed. Please install git to proceed." >&2
    exit 1
fi

if ! command_exists curl; then
    echo "Error: curl is not installed. Please install curl to proceed." >&2
    exit 1
fi

if ! command_exists wget; then
	echo "Error: wget is not installed. Please install wget to proceed." >&2
	exit 1
fi

# Install Homebrew
BREW_PATH="$HOME/.local/bin"

install_brew() {
    if [[ "$EXPRESS_INSTALL" == false ]]; then
        # Prompt user to choose installation method
        echo "${B}${YEL}Choose ${GRN}Homebrew ${YEL}installation method:${D}"
        echo "${YEL}(1)${D} Custom Installation @ ${BREW_PATH}"
		echo "${YEL}(2)${D} Official Installation Script (requires sudo)"
        read -r install_method
        case $install_method in
            1)
                # Custom Installation
                mkdir -p ~/.local/Homebrew &&
                curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.local/Homebrew
                # Link Binary to preferred PATH
                mkdir -p ${BREW_PATH} &&
                ln -s ~/.local/Homebrew/bin/brew ${BREW_PATH}
                ;;
            2)
                # Official Installation Script
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                echo "${YEL}Homebrew installed using ${PRP}official script.${D}"
                ;;
            *)
                echo "Invalid option selected. Continuing..."
                return 1
                ;;
        esac
    else
        echo "${YEL}Express install mode enabled. Skipping Homebrew installation prompt.${D}"
    fi
}

uninstall_brew() {
	if [[ -f "${BREW_PATH}/brew" ]]; then
        echo "${YEL}Custom Homebrew installation found. ${PRP}Uninstalling...${D}"
        rm -f "${BREW_PATH}/brew"
        echo "${YEL}Custom Homebrew uninstalled.${D}"
    elif command -v brew &> /dev/null; then
        echo "${YEL}Homebrew installed using official script found. ${PRP}Uninstalling...${D}"
        rm -f "/home/linuxbrew/.linuxbrew/bin/brew"
        echo "${YEL}Homebrew uninstalled.${D}"
    else
        echo "${YEL}No Homebrew installation found. ${PRP}Continuing...${D}"
    fi
	install_brew
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
    echo "${GRN}${B}Homebrew ${PRP}Setup 🍺${D}"
	echo "${YEL}Checking if Homebrew is installed...${D}"
	if ! $(which brew); then
		echo "$(which brew)"
	fi
	echo "${B}Select an option:${D}"
	echo "${YEL}(1)${D} Install Homebrew"
	echo "${YEL}(2)${D} Uninstall Homebrew"
	read -r option

	case $option in
		1)
			if ! command -v brew &> /dev/null; then
				install_brew
			else
				echo "${GRN}Homebrew ${YEL}is already installed. ${PRP}🖒 ${D}"
			fi
			;;
		2)
			uninstall_brew
			;;
		*)
			echo "${YEL}Invalid option selected. ${B}Continuing...${D}"
			;;
	esac
else
	install_brew
fi

# Associative array defining Homebrew packages to install
declare -A BREW_PACKAGES
BREW_PACKAGES=(
	["readline"]="readline"
	["node"]="node"
    ["unzip"]="unzip"
    ["btop"]="Btop"
    ["lnav"]="Lnav"
    ["lazygit"]="Lazygit"
    ["nvim"]="Neovim"
    ["rg"]="Ripgrep"
    ["starship"]="Starship"
    ["atuin"]="Atuin"
    ["cowsay"]="Cowsay"
    ["fortune"]="Fortune"
    ["lolcat"]="Lolcat"
    ["eza"]="Eza"
    ["zoxide"]="Zoxide"
    ["atuin"]="Atuin"
    ["fzf"]="Fzf"
    ["ranger"]="Ranger"
)

# Ask to install Homebrew packages
install_brew_packages() {
    for package in "${!BREW_PACKAGES[@]}"; do
		echo "${YEL}Installing ${GRN}${B}${BREW_PACKAGES[$package]}${D}${YEL}...${D}"
        brew install "$package" --force-bottle
        echo "${YEL}Installed ${GRN}${B}${BREW_PACKAGES[$package]}${D} 🍺"
    done
	# List installed Homebrew packages
	echo "${YEL}Installed ${GRN}Homebrew ${YEL}packages 🍺:${D}"
	brew list
}

echo "${PRP}${B}Do you want to install ${GRN}Homebrew${PRP} packages? 🍻 ${YEL}(y/n)${D}"
if [[ "$EXPRESS_INSTALL" == false ]]; then
	read -r install_packages
	if [[ "$install_packages" =~ ^[Yy]$ ]]; then
		install_brew_packages
	else
		echo "${YEL}Skipping ${GRN}${B}Homebrew ${D}${YEL}packages installation.${D}"
	fi
else
	install_brew_packages
fi

# Installing Kitty
install_kitty() {
	echo "Installing kitty Terminal emulator..."
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	ln -s ~/.local/kitty.app/bin/kitty /usr/local/bin/
	ln -s ~/.dotfiles/kitty/dracula.conf ~/.config/kitty/dracula.conf
	ln -s ~/.dotfiles/kitty/diff.conf ~/.config/kitty/diff.conf
	echo "${YEL}${B}kitty installation complete 😻${D}"
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "${PRP}${B}Do you want to install ${RED}kitty ${PRP}terminal emulator${D}? ${YEL}(y/n)${D}"
	read -r install_kitty
	if [[ "$install_kitty" =~ ^[Yy]$ ]]; then
		if [[ ! -d "$HOME/.local/kitty.app" ]]; then
			install_kitty
		else
			echo "${YEL}kitty is already installed 😻${D}"
		fi
	else
		echo "${YEL}Skipping ${RED}kitty ${YEL}installation.${D}"
	fi
else
	install_kitty
fi

# Get FiraCode font
FONT_NAME="FiraCode"
FONT_DIR="$HOME/.local/share/fonts"
TEMP_DIR="$(mktemp -d)"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"

is_gui_environment() {
    if command -v xset &> /dev/null && xset q &> /dev/null; then
        return 0  # GUI environment detected
    else
        return 1  # No GUI environment
    fi
}

get_firacode() {
	# Create temporary directory
	if [ ! -d "$FONT_DIR" ]; then
		mkdir -p "$FONT_DIR"
	fi
	echo "${YEL}Downloading $FONT_NAME Nerd Font...${D}"
	wget -qO "$TEMP_DIR/$FONT_NAME.zip" "$FONT_URL"
	echo "${YEL}Unzipping the font...${D}"
	unzip -q "$TEMP_DIR/$FONT_NAME.zip" -d "$TEMP_DIR"
	echo "${YEL}Installing the font...${D}"
	mv "$TEMP_DIR"/*.ttf "$FONT_DIR/"
	if is_gui_environment; then
        echo "${YEL}Updating the font cache...${D}"
        fc-cache -fV
    else
        echo "${YEL}No GUI environment detected, skipping font cache update.${D}"
    fi
	# Clean up
	rm -rf "$TEMP_DIR"
	echo "${PRP}$FONT_NAME ${YEL}Nerd Font installed successfully! 🤙${D}"
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "${PRP}${B}Do you want to install ${RED}FiraCode ${PRP}font? ${YEL}(y/n)${D}"
	read -r install_firacode
	if [[ "$install_firacode" =~ ^[Yy]$ ]]; then
		get_firacode
	else
		echo "${YEL}Skipping ${RED}FiraCode ${YEL}font installation.${D}"
	fi
else
	get_firacode
fi

echo "${B}${GRN}󰄬 ${PRP}${USER}${YEL}'s Dev Environment Setup complete. ${GRN}💻${D}"
