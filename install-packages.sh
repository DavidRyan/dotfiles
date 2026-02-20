#!/bin/bash
# Cross-platform Package Installation Script
# Installs packages for macOS (Homebrew) or Linux (pacman/apt)

set -e

echo "=============================="
echo "  Package Installation"
echo "=============================="
echo ""

# Detect OS
OS="$(uname)"

# ── macOS Installation ─────────────────────────────────────────────────────────

install_macos_packages() {
    echo "Detected: macOS"
    echo ""

    # Check for Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add brew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    echo "── Installing Homebrew formulae ──"

    local formulae=(
        bat
        eza
        fd
        fzf
        git
        neovim
        ripgrep
        starship
        stow
        zoxide
        zsh
    )

    local casks=(
        ghostty
        hammerspoon
        kitty
    )

    local taps=(
        "nikitabobko/tap"       # aerospace
        "FelixKratz/formulae"   # sketchybar, borders
    )

    local tap_formulae=(
        "nikitabobko/tap/aerospace"
        "FelixKratz/formulae/sketchybar"
        "FelixKratz/formulae/borders"
    )

    # Add taps
    echo ""
    echo "Adding taps..."
    for tap in "${taps[@]}"; do
        echo "  [tap] $tap"
        brew tap "$tap" 2>/dev/null || true
    done

    # Install formulae
    echo ""
    echo "Installing formulae..."
    for pkg in "${formulae[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            echo "  [ok]   $pkg"
        else
            echo "  [install] $pkg"
            brew install --quiet "$pkg" || true
        fi
    done

    # Install casks
    echo ""
    echo "Installing casks..."
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            echo "  [ok]   $cask"
        else
            echo "  [install] $cask"
            brew install --quiet --cask "$cask" || true
        fi
    done

    # Install tap formulae
    echo ""
    echo "Installing tap formulae..."
    for pkg in "${tap_formulae[@]}"; do
        local name="${pkg##*/}"
        if brew list "$name" &>/dev/null; then
            echo "  [ok]   $name"
        else
            echo "  [install] $name"
            brew install --quiet "$pkg" || true
        fi
    done

    echo ""
    echo "macOS package installation complete."
}

# ── Linux Installation ─────────────────────────────────────────────────────────

install_linux_packages() {
    echo "Detected: Linux"
    echo ""

    # Detect package manager
    if command -v pacman &>/dev/null; then
        install_arch_packages
    elif command -v apt &>/dev/null; then
        install_debian_packages
    elif command -v dnf &>/dev/null; then
        install_fedora_packages
    else
        echo "Error: No supported package manager found (pacman, apt, dnf)"
        exit 1
    fi
}

install_arch_packages() {
    echo "Package manager: pacman (Arch Linux)"
    echo ""

    # Check if running as root
    if [[ "$EUID" -eq 0 ]]; then 
        echo "Warning: Don't run this script as root. It will use sudo when needed."
        exit 1
    fi

    # Update system first
    echo "Updating system..."
    sudo pacman -Syu --noconfirm

    # Ensure base-devel is installed
    echo ""
    echo "Ensuring base-devel is installed..."
    sudo pacman -S --needed --noconfirm base-devel

    # Official repository packages
    echo ""
    echo "Installing official packages..."
    local official_packages=(
        atop
        bat
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
        eza
        fastfetch
        fd
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
        ripgrep
        rofi
        rust
        sddm
        sddm-kcm
        slurp
        smartmontools
        starship
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
        wofi
        wpa_supplicant
        xdg-desktop-portal-hyprland
        xdg-utils
        xorg-server
        xorg-xinit
        zoxide
        zram-generator
        zsh
    )

    sudo pacman -S --needed --noconfirm "${official_packages[@]}"

    # Install AUR helper if needed
    if ! command -v paru &>/dev/null && ! command -v yay &>/dev/null; then
        echo ""
        echo "Installing paru (AUR helper)..."
        cd /tmp
        rm -rf paru
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ~
    fi

    # Determine AUR helper
    local aur_helper=""
    if command -v paru &>/dev/null; then
        aur_helper="paru"
    elif command -v yay &>/dev/null; then
        aur_helper="yay"
    fi

    if [[ -n "$aur_helper" ]]; then
        echo ""
        echo "Installing AUR packages with $aur_helper..."
        local aur_packages=(
            cbonsai
            chatgpt-desktop-bin
            git-credential-manager
            hpaper
            neofetch
            opencode-bin
            pokeget
            vtop
        )

        # Install yay if using paru (for compatibility)
        if [[ "$aur_helper" == "paru" ]]; then
            aur_packages+=("yay")
        fi

        $aur_helper -S --needed --noconfirm "${aur_packages[@]}" || true
    fi

    echo ""
    echo "Arch Linux package installation complete."
}

install_debian_packages() {
    echo "Package manager: apt (Debian/Ubuntu)"
    echo ""

    # Update package lists
    echo "Updating package lists..."
    sudo apt update

    # Common packages available in Debian/Ubuntu
    local packages=(
        bat
        curl
        fd-find
        fzf
        git
        neovim
        ripgrep
        stow
        zsh
    )

    echo ""
    echo "Installing packages..."
    sudo apt install -y "${packages[@]}"

    # Install starship
    if ! command -v starship &>/dev/null; then
        echo ""
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Install eza (modern ls)
    if ! command -v eza &>/dev/null; then
        echo ""
        echo "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi

    # Install zoxide
    if ! command -v zoxide &>/dev/null; then
        echo ""
        echo "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    echo ""
    echo "Debian/Ubuntu package installation complete."
}

install_fedora_packages() {
    echo "Package manager: dnf (Fedora)"
    echo ""

    # Common packages
    local packages=(
        bat
        eza
        fd-find
        fzf
        git
        neovim
        ripgrep
        stow
        zoxide
        zsh
    )

    echo "Installing packages..."
    sudo dnf install -y "${packages[@]}"

    # Install starship
    if ! command -v starship &>/dev/null; then
        echo ""
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    echo ""
    echo "Fedora package installation complete."
}

# ── Main ───────────────────────────────────────────────────────────────────────

case "$OS" in
    Darwin)
        install_macos_packages
        ;;
    Linux)
        install_linux_packages
        ;;
    *)
        echo "Error: Unsupported operating system: $OS"
        exit 1
        ;;
esac

echo ""
echo "=============================="
echo "  Installation Complete!"
echo "=============================="
echo ""
echo "Next step: Run the appropriate setup script to stow dotfiles:"
echo "  macOS: ./setup-macos.sh"
echo "  Linux: ./setup-linux.sh"
