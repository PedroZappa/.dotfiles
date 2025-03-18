#!/bin/bash

# Exit the script if any command fails
set -e

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

# Check if yay is installed
if ! command -v yay > /dev/null 2>&1; then
    echo "yay is not installed. Installing yay..."
    # Install git if it's not already present
    sudo pacman -S --needed git
    # Install base-devel group if any packages are missing
    sudo pacman -S --needed base-devel
    # Create a temporary directory to build yay
    TMPDIR=$(mktemp -d)
    # Clone the yay repository from the AUR
    git clone https://aur.archlinux.org/yay.git "$TMPDIR"
    # Navigate to the cloned directory
    cd "$TMPDIR"
    # Build and install yay (this will prompt for sudo when installing)
    makepkg -si
    # Return to the previous directory and clean up
    cd -
    rm -rf "$TMPDIR"
else
    echo "yay is already installed."
fi

# Array of packages to install
packages=(
    # # Essentials
    "grub" # bootloader
    "ufw" # firewall
    "man-db"
    "man-pages"
    "tzdata" # time sync
    "ncdu" # disk usage
    "btop" # top replacement
    "iotop" # I/O monitoring
    # Essential Lulz
    "c-lolcat"
    "cowsay"
    "fortune-mod"
    "toilet"
    "boxes"
    "ascii-image-converter-git"
    "shell-color-scripts-git"
    "cmatrix"
    # Networking
    "iftop" # Network Monitoring
    "mtr" # Network diagnostics
    "iperf3"
    "dnsutils" # dig $ nslookup
    "ldns" # Provides drill
    "aria2" # download protocol
    "socat" # replacement for openbsd-netcat
    "nmap" # Netwrk Discovery and Auditing
    "ipcalc" # IPv4/v6 address calculator
    "iw" # wireless tools
    # System Call Monitoring
    "strace" # System call monitoring
    "ltrace" # Library Call monitoring
    "lsof" # List ofpen files
    # System Tools
    "sysstat"
    "lm_sensors" # sensors cmd
    "ethtool" # network tools
    "pciutils" # PCI bus tools
    "usbutils" # USB tools
    # Terminal Tools
    "ghostty"
    "zsh"
    "starship"
    "neovim"
    "tmux"
    "lnav"
    "bat"
    # Git
    "git"
    "lazygit"
    "github-cli"
    # Navigation
    "ripgrep"
    "eza"
    "atuin"
    "zoxide"
    "ranger"
    "fzf"
    # Font
    "ttf-firacode-nerd"
    "ttf-font-awesome"
    "otf-font-awesome"
    "ttf-nerd-fonts-symbols"
    "noto-fonts"
    "noto-fonts-emoji"
    "ttf-dejavu"
    # Build tools
    "clang"
    "cmake"
    # C/C++
    "gdb"
    "valgrind"
    # Python
    "python-pip"
    "uv"
    # Rust
    "cargo"
    # Docker
    "docker"
    "docker-compose"
    "lazydocker"
    # Web
    "google-chrome"
    "nodejs"
    "npm"
    "yarn"
    # Markdown
    "glow"
    # Bluetooth
    "bluez"
    "bluez-utils"
    "bluetui"
    # IRC
    "weechat"
    "python-websocket-client"
    # Docker
    "ggshield" # vulnerability scanner

    # GNOME
    "chrome-gnome-shell"

    # Hyprland
    "hyprland"
    "hyprlock"
    "hypridle"
    "hyprpaper"
    "hyprshot" # Scheenshort Manager
    "fuzzel" # App Launcher
    "clipse" # clipboard Manager
    "swaync" # Notifications
    "waybar" # navbar
    "eww" # widgets
)

packages_uv=(
    "posting"
)

# Loop through the array and install each package
for pkg in "${packages[@]}"; do
    echo "Installing $pkg..."
    yay -S --noconfirm "$pkg"
done

for pkg in "${packages_uv[@]}"; do
    echo "Installing $pkg..."
    uv tool install "$pkg"
done

pip install gcop --break-system-packages

echo "All packages installed successfully!"
