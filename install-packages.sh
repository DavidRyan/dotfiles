#!/bin/bash
# Arch Linux Package Installation Script
# This script reinstalls all user-installed packages from your previous system

set -e  # Exit on error

echo "=================================="
echo "Arch Linux Package Reinstall Script"
echo "=================================="
echo ""

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo "Error: This script is designed for Arch Linux (pacman not found)"
    exit 1
fi

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "Warning: Don't run this script as root. It will use sudo when needed."
    exit 1
fi

echo "This script will install:"
echo "  - AUR helper (paru or yay)"
echo "  - All official repository packages"
echo "  - All AUR packages"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Update system first
echo ""
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install base and base-devel if not already installed
echo ""
echo "Ensuring base and base-devel are installed..."
sudo pacman -S --needed --noconfirm base base-devel

# Official repository packages (excluding AUR packages)
echo ""
echo "Installing official repository packages..."
OFFICIAL_PACKAGES=(
    atop
    bc
    bluez
    bluez-utils
    bottom
    brightnessctl
    btrfs-progs
    cava
    chromium
    cliphist
    cmatrix
    dolphin
    dunst
    efibootmgr
    fastfetch
    feh
    ffmpegthumbnailer
    fzf
    ghostty
    git
    greetd
    grim
    gst-plugin-pipewire
    htop
    hyprland
    hyprlock
    hyprpaper
    imwheel
    intel-media-driver
    intel-ucode
    iwd
    kitty
    libpulse
    libva-intel-driver
    linux
    linux-firmware
    nano
    neovim
    nsxiv
    openssh
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    polkit-kde-agent
    qt5-quickcontrols2
    qt5-wayland
    qt6-wayland
    ranger
    rofi
    rust
    sddm
    sddm-kcm
    slurp
    smartmontools
    stow
    swaybg
    thunar
    thunar-volman
    ttf-dejavu
    ttf-fira-code
    ttf-jetbrains-mono-nerd
    tumbler
    unzip
    uwsm
    vim
    vulkan-intel
    waybar
    wget
    wireless_tools
    wireplumber
    wl-clipboard
    woff2-font-awesome
    wofi
    wpa_supplicant
    xdg-desktop-portal-hyprland
    xdg-utils
    xorg-server
    xorg-xinit
    zram-generator
    zsh
)

sudo pacman -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"

# Install AUR helper (paru) if not already installed
if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then
    echo ""
    echo "Installing paru (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
else
    echo ""
    echo "AUR helper already installed, skipping..."
fi

# Determine which AUR helper to use
if command -v paru &> /dev/null; then
    AUR_HELPER="paru"
elif command -v yay &> /dev/null; then
    AUR_HELPER="yay"
else
    echo "Error: No AUR helper found!"
    exit 1
fi

# AUR packages
echo ""
echo "Installing AUR packages with $AUR_HELPER..."
AUR_PACKAGES=(
    cbonsai
    chatgpt-desktop-bin
    git-credential-manager
    hpaper
    neofetch
    opencode-bin
    pokeget
    vtop
    yay
)

$AUR_HELPER -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo ""
echo "=================================="
echo "Installation Complete!"
echo "=================================="
echo ""
echo "Installed:"
echo "  - ${#OFFICIAL_PACKAGES[@]} official repository packages"
echo "  - ${#AUR_PACKAGES[@]} AUR packages"
echo ""
echo "Next steps:"
echo "  1. Set up your dotfiles (use stow if needed)"
echo "  2. Install oh-my-zsh: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
echo "  3. Configure services (e.g., sudo systemctl enable sddm, bluetooth, etc.)"
echo "  4. Copy wallpapers to ~/Pictures/wallpapers and ~/walls-catppuccin-mocha"
echo "  5. Install swaync config if needed"
echo ""
