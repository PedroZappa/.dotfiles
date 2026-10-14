#!/bin/bash

# set -e

###############################################################################
# Colors
###############################################################################

if [ -d "$HOME/.dotfiles" ]; then
    source "$HOME/.dotfiles/scripts/colors.sh"
else
    if [ ! -f "$HOME/colors.sh" ]; then
        echo "Colors script not found, downloading..."
        wget -O "$HOME/colors.sh" \
            https://raw.githubusercontent.com/PedroZappa/.dotfiles.min/refs/heads/main/scripts/colors.sh
    fi

    source "$HOME/colors.sh"
fi


###############################################################################
# Detect environment
###############################################################################

IS_OMARCHY=false

if command -v omarchy >/dev/null 2>&1 || [ -d /usr/share/omarchy ]; then
    IS_OMARCHY=true
fi

if $IS_OMARCHY; then
    echo -e "${GRN}Omarchy detected.${D}"
else
    echo -e "${YEL}Standard Arch Linux detected.${D}"
fi


###############################################################################
# Package installation helper
###############################################################################

install_package() {
    local pkg="$1"

    echo -e "${CYN}Installing ${pkg}...${D}"

    if $IS_OMARCHY; then
        omarchy pkg add "$pkg"
    else
        yay -S --needed --noconfirm "$pkg"
    fi
}


###############################################################################
# AUR package installation helper
###############################################################################

install_aur_package() {
    local pkg="$1"

    echo -e "${CYN}Installing AUR package ${pkg}...${D}"

    if $IS_OMARCHY; then
        omarchy pkg aur add "$pkg"
    else
        yay -S --needed --noconfirm "$pkg"
    fi
}


###############################################################################
# Install yay on normal Arch
###############################################################################

if ! command -v yay >/dev/null 2>&1; then

    # Omarchy already provides yay
    if $IS_OMARCHY; then
        echo -e "${GRN}Omarchy already provides yay.${D}"
    else
        echo -e "${YEL}yay is not installed. Installing yay...${D}"

        sudo pacman -S --needed --noconfirm git base-devel

        TMPDIR=$(mktemp -d)

        git clone https://aur.archlinux.org/yay.git "$TMPDIR/yay"

        (
            cd "$TMPDIR/yay"
            makepkg -si
        )

        rm -rf "$TMPDIR"
    fi
else
    echo -e "${GRN}yay is already installed.${D}"
fi


###############################################################################
# Personal packages
#
# These are packages YOU want regardless of whether you're running:
#
#   Arch
#   Omarchy
#
###############################################################################

packages=(

    # -------------------------------------------------------------------------
    # Arch / System
    # -------------------------------------------------------------------------

    reflector
    man-db
    man-pages
    tzdata
    ncdu
    btop
    iotop

    # -------------------------------------------------------------------------
    # Essential Lulz
    # -------------------------------------------------------------------------

    c-lolcat
    cowsay
    fortune-mod
    toilet
    boxes
    cmatrix

    # -------------------------------------------------------------------------
    # Networking
    # -------------------------------------------------------------------------

    iftop
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc
    iw

    # -------------------------------------------------------------------------
    # System Call Monitoring
    # -------------------------------------------------------------------------

    strace
    ltrace
    lsof

    # -------------------------------------------------------------------------
    # System Tools
    # -------------------------------------------------------------------------

    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils

    # -------------------------------------------------------------------------
    # Terminal
    # -------------------------------------------------------------------------

    ghostty
    zsh
    starship
    neovim
    tmux
    lnav
    bat

    # -------------------------------------------------------------------------
    # Git
    # -------------------------------------------------------------------------

    git
    lazygit
    github-cli

    # -------------------------------------------------------------------------
    # Navigation
    # -------------------------------------------------------------------------

    ripgrep
    eza
    atuin
    zoxide
    ranger
    fzf

    # -------------------------------------------------------------------------
    # Fonts
    # -------------------------------------------------------------------------

    ttf-firacode-nerd
    ttf-font-awesome
    otf-font-awesome
    ttf-nerd-fonts-symbols
    noto-fonts
    noto-fonts-emoji
    ttf-dejavu

    # -------------------------------------------------------------------------
    # Build / C / C++
    # -------------------------------------------------------------------------

    llvm
    clang
    cmake
    gdb
    valgrind

    # -------------------------------------------------------------------------
    # Python
    # -------------------------------------------------------------------------

    python-pip
    uv

    # -------------------------------------------------------------------------
    # Rust
    # -------------------------------------------------------------------------

    cargo

    # -------------------------------------------------------------------------
    # Docker
    # -------------------------------------------------------------------------

    docker
    docker-compose
    lazydocker
    nvidia-container-toolkit

    # -------------------------------------------------------------------------
    # Web
    # -------------------------------------------------------------------------

    google-chrome
    chromium
    nodejs
    npm
    yarn

    # -------------------------------------------------------------------------
    # Markdown
    # -------------------------------------------------------------------------

    glow

    # -------------------------------------------------------------------------
    # Bluetooth
    # -------------------------------------------------------------------------

    bluez
    bluez-utils
    bluetui

    # -------------------------------------------------------------------------
    # IRC
    # -------------------------------------------------------------------------

    weechat
    python-websocket-client

    # -------------------------------------------------------------------------
    # Docker security
    # -------------------------------------------------------------------------

    ggshield

    # -------------------------------------------------------------------------
    # GNOME compatibility
    # -------------------------------------------------------------------------

    chrome-gnome-shell

    # -------------------------------------------------------------------------
    # Spotify
    # -------------------------------------------------------------------------

    spotify
    spotify-player
)


###############################################################################
# AUR packages
#
# Keep packages that aren't guaranteed to be in the Arch repositories here.
###############################################################################

aur_packages=(
    ascii-image-converter-git
    shell-color-scripts-git
    hyprpicker-git
)


###############################################################################
# Desktop packages
#
# These are intentionally NOT installed on Omarchy.
#
# Omarchy already provides its own Hyprland desktop stack.
###############################################################################

arch_desktop_packages=(

    hyprland
    hyprlock
    hypridle
    hyprpaper
    hyprpicker-git
    hyprshot
    fuzzel
    clipse
    swaync
    waybar
    eww
)


###############################################################################
# Install normal packages
###############################################################################

echo
echo "========================================"
echo " Installing personal packages"
echo "========================================"
echo

for pkg in "${packages[@]}"; do
    install_package "$pkg"
done


###############################################################################
# Install AUR packages
###############################################################################

echo
echo "========================================"
echo " Installing AUR packages"
echo "========================================"
echo

for pkg in "${aur_packages[@]}"; do
    install_aur_package "$pkg"
done


###############################################################################
# Install Hyprland desktop on normal Arch
###############################################################################

if $IS_OMARCHY; then

    echo
    echo "========================================"
    echo " Omarchy desktop detected"
    echo "========================================"
    echo
    echo "Skipping standalone Hyprland packages."
    echo "Omarchy already manages the desktop stack."

else

    echo
    echo "========================================"
    echo " Installing Hyprland desktop"
    echo "========================================"
    echo

    for pkg in "${arch_desktop_packages[@]}"; do
        install_package "$pkg"
    done

fi


###############################################################################
# uv tools
###############################################################################

if command -v uv >/dev/null 2>&1; then

    echo
    echo "========================================"
    echo " Installing uv tools"
    echo "========================================"
    echo

    uv tool install "posting" --prerelease=allow

else
    echo -e "${RED}uv is not installed. Skipping uv tools.${D}"
fi


###############################################################################
# Finished
###############################################################################

echo
echo -e "${GRN}========================================${D}"
echo -e "${GRN} All packages installed successfully! ${D}"
echo -e "${GRN}========================================${D}"
