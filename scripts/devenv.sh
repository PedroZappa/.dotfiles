#!/usr/bin/env bash
set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

### Dev Environment Setup
# Sources:
# Brew without sudo
# https://nelsonaloysio.medium.com/installing-homebrew-without-sudo-5e708a929522

# Check bash version for associative array support
if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    echo "Error: This script requires bash version 4.0 or higher." >&2
    exit 1
fi

# Ensure git and curl are installed
command_exists() {
    command -v "$1" &> /dev/null
}

if ! command_exists git; then
    echo "Error: git is not installed. Please install git to proceed." >&2
    exit 1
fi

if ! command_exists curl; then
    echo "Error: curl is not installed. Please install curl to proceed." >&2
    exit 1
fi

# Express installation
# Check for --express argument
EXPRESS_INSTALL=false
if [[ $# -gt 0 && "$1" == "--express" ]]; then
    EXPRESS_INSTALL=true
fi

BREW_PATH="$HOME/.local/bin"

# Associative array defining source and target FILES
declare -A FILES
FILES=(
    ["$HOME/.dotfiles/.bashrc"]="$HOME/.bashrc"
    ["$HOME/.dotfiles/.gitconfig"]="$HOME/.gitconfig"
    ["$HOME/.dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$HOME/.dotfiles/.zshenv"]="$HOME/.zshenv"
    ["$HOME/.dotfiles/.gdbinit"]="$HOME/.gdbinit"
	["$HOME/.dotfiles/starship.toml"]="$HOME/.config/starship.toml"
    ["$HOME/.dotfiles/.vimrc"]="$HOME/.vimrc"
    ["$HOME/.dotfiles/nvim"]="$HOME/.config/nvim"
    ["$HOME/.dotfiles/.tmux.conf.local"]="$HOME/.config/.tmux.conf.local"
    ["$HOME/.dotfiles/kitty/kitty.conf"]="$HOME/.config/kitty/kitty.conf"
    ["$HOME/.dotfiles/btop/btop.conf"]="$HOME/.config/btop/btop.conf"
    ["$HOME/.dotfiles/atuin/config.toml"]="$HOME/.config/atuin/config.toml"
)

# Associative array defining Homebrew packages to install
declare -A BREW_PACKAGES
BREW_PACKAGES=(
	["zsh"]="Zsh"
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
)

# clone .dotfiles repository
clone_dotfiles() {
	if [[ ! -d "$HOME/.dotfiles" ]]; then
		cd "$HOME"
		git clone https://github.com/PedroZappa/zedro-dotfiles ./.dotfiles
		echo ".dotfiles repository successfully cloned. 󰩑 "
	else
		echo ".dotfiles repository already exists. 󰩑 "
	fi
}

echo "Starting Dev Environment Setup"
if [[ "$EXPRESS_INSTALL" == false ]]; then
    echo "Do you want to clone Zedro's .dotfiles repository? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
		if [ ! -d "$HOME/.dotfiles" ]; then
			clone_dotfiles
		fi
	else
		echo ".dotfiles repository already exists. 󰩑 "
    fi
else
    clone_dotfiles
fi

# Install Homebrew
install_brew() {
	if [[ "$EXPRESS_INSTALL" == false ]]; then
		echo "Homebrew not found. Do you want to install it? (y/n)"
		read -r response
		if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Homebrew installation skipped."
            return
        fi
	fi
	# Get Homebrew Package
	mkdir -p ~/.local/Homebrew &&
	curl -L https://github.com/Homebrew/brew/tarball/master |
	tar xz --strip 1 -C ~/.local/Homebrew
	# Link Binary to prefered PATH
	mkdir -p ${BREW_PATH} &&
	ln -s ~/.local/Homebrew/bin/brew ${BREW_PATH}
	# Add Homebrew to PATH
	if [ -n $(command -v brew) ]; then
		export PATH="$PATH:$BREW_PATH"
		PREFIX="${HOME}/.local"
		export HOMEBREW_PREFIX="$PREFIX"
		export HOMEBREW_CELLAR="$PREFIX/Cellar"
		export HOMEBREW_REPOSITORY="$PREFIX/Homebrew"
		export PATH="$PREFIX/bin:$PREFIX/sbin${PATH+:$PATH}"
		export MANPATH="$PREFIX/share/man${MANPATH+:$MANPATH}:"
		export INFOPATH="$PREFIX/share/info:${INFOPATH:-}"
		# export HOMEBREW_NO_ANALYTICS=1
		# export HOMEBREW_NO_ENV_HINTS=1
		echo "Homebrew env vars configuration complete. 🖒 "
	fi
}

if ! command -v brew &> /dev/null; then
    install_brew
else
    echo "Homebrew is already installed. 🖒 "
fi

# Ask to install Homebrew packages
install_brew_packages() {
    for package in "${!BREW_PACKAGES[@]}"; do
		echo "Installing ${BREW_PACKAGES[$package]}... 🮲"
        brew install "$package" --force-bottle
        echo "Installed ${BREW_PACKAGES[$package]} 🤙"
    done
	# List installed Homebrew packages
	echo "Installed Homebrew packages 🍺:"
	brew list
}

echo "Do you want to install Homebrew packages now? (y/n)"
if [[ "$EXPRESS_INSTALL" == false ]]; then
	read -r install_packages
	if [[ "$install_packages" =~ ^[Yy]$ ]]; then
		install_brew_packages
	fi
else
	install_brew_packages
fi

# Install zap, zsh's Package Manager
install_zap() {
	echo "Installing zap: zsh's Package Manager..."
	zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
	echo "zap installation complete. 🤙"
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "Do you want to install zap now? (y/n)"
	read -r install_zap
	if [[ "$install_zap" =~ ^[Yy]$ ]]; then
		if [[ ! -d "$ZAP_DIR" ]]; then
			install_zap
		else
			echo "zap already installed. 🤙"
		fi
	fi
else
	install_zap
fi
# Install oh-my-tmux
install_oh_my_tmux() {
    echo "Installing oh-my-tmux..."
    cd "$HOME"
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    echo "oh-my-tmux installation complete."
}

echo "Do you want to install oh-my-tmux now? (y/n)"
read -r install_tmux
if [[ "$install_tmux" =~ ^[Yy]$ ]]; then
    install_oh_my_tmux
fi

# Installing Kitty
install_kitty() {
	echo "Installing kitty Terminal emulator..."
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	echo "kitty installation complete 😻"
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "Do you want to install kitty now? (y/n)"
	read -r install_kitty
	if [[ "$install_kitty" =~ ^[Yy]$ ]]; then
		if [[ ! -d "$HOME/.local/kitty.app" ]]; then
			install_kitty
		else
			echo "kitty is already installed 😻"
		fi
	fi
else
	install_kitty
fi

# Create symlinks to .dotfiles
create_symlink() {
    local SRC=$1
    local DEST=$2

    # Check if the destination file/directory exists
    if [ -e "$DEST" ]; then
        # If it exists, move it to a backup
        mv "$DEST" "${DEST}_bak"
        echo "Moved existing $DEST to ${DEST}_bak"
    fi
    # Create the parent directory if it doesn't exist
    mkdir -p "$(dirname "$DEST")"
    # Create the symlink
    ln -s "$SRC" "$DEST"
    echo "Created symlink from $SRC to $DEST" 🖒
}

if [[ "$EXPRESS_INSTALL" == false ]]; then
	echo "Do you want to create symlinks to .dotfiles now? (y/n)"
	read -r create_symlinks
	if [[ "$create_symlinks" =~ ^[Yy]$ ]]; then
		for SRC in "${!FILES[@]}"; do
			DEST=${FILES[$SRC]}
			create_symlink "$SRC" "$DEST"
		done
	fi
else
	for SRC in "${!FILES[@]}"; do
		DEST=${FILES[$SRC]}
		create_symlink "$SRC" "$DEST"
	done
fi

echo "${USER} Dev Environment Setup complete."
