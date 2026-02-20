#!/bin/bash
# Linux Dotfiles Setup Script
# 1. Installs packages via install-packages.sh
# 2. Uses GNU Stow to symlink dotfiles

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"

# Linux-specific stow packages
LINUX_PACKAGES=(
    colors
    ghostty
    hypr
    kitty
    nvim
    rofi
    waybar
    zsh
)

# Packages that exist in the repo but are macOS-only
MACOS_ONLY=(
    aerospace
    android-studio
    borders
    hammerspoon
    sketchybar
)

echo "=============================="
echo "  Linux Dotfiles Setup"
echo "=============================="
echo ""
echo "Dotfiles dir: $DOTFILES_DIR"
echo "Target dir:   $TARGET_DIR"
echo ""

# ── Preflight checks ──────────────────────────────────────────────────────────

if [[ "$(uname)" != "Linux" ]]; then
    echo "Error: This script is for Linux only."
    exit 1
fi

# ── Step 1: Install packages ──────────────────────────────────────────────────

echo "── Step 1: Installing packages ──"
echo ""

if [[ -f "$DOTFILES_DIR/install-packages.sh" ]]; then
    bash "$DOTFILES_DIR/install-packages.sh"
else
    echo "Warning: install-packages.sh not found, skipping package installation."
fi

# ── Step 2: Stow dotfiles ─────────────────────────────────────────────────────

# Verify stow is now available
if ! command -v stow &>/dev/null; then
    echo "Error: GNU Stow not found after package installation."
    echo "Install it manually:"
    echo "  Arch:   sudo pacman -S stow"
    echo "  Debian: sudo apt install stow"
    echo "  Fedora: sudo dnf install stow"
    exit 1
fi

echo ""
echo "── Step 2: Stowing dotfiles ──"
echo ""

stow_package() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        echo "  [skip] $pkg (directory not found)"
        return
    fi

    echo "  [stow] $pkg"
    stow --dir="$DOTFILES_DIR" --target="$TARGET_DIR" --restow "$pkg" 2>&1 | \
        sed 's/^/         /'
}

for pkg in "${LINUX_PACKAGES[@]}"; do
    stow_package "$pkg"
done

# ── Step 3: Hyprland post-setup (optional) ────────────────────────────────────

setup_hyprland() {
    echo ""
    echo "── Hyprland post-setup ──"

    # Enable common services
    local services=(sddm bluetooth)
    for svc in "${services[@]}"; do
        if systemctl list-unit-files "$svc.service" &>/dev/null; then
            echo "  [enable] $svc"
            sudo systemctl enable "$svc" 2>/dev/null || true
        fi
    done

    # Create wallpaper directory
    mkdir -p ~/Pictures/wallpapers
    echo "  [create] ~/Pictures/wallpapers"
}

echo ""
read -p "Run Hyprland post-setup (enable services, create dirs)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    setup_hyprland
fi

# ── Complete ──────────────────────────────────────────────────────────────────

echo ""
echo "=============================="
echo "  Setup Complete!"
echo "=============================="
echo ""
echo "Stowed packages:"
for pkg in "${LINUX_PACKAGES[@]}"; do
    echo "  - $pkg"
done
echo ""
echo "Skipped (macOS-only):"
for pkg in "${MACOS_ONLY[@]}"; do
    echo "  - $pkg"
done
echo ""
echo "Next steps:"
echo "  1. Reload shell:       source ~/.zshrc"
echo "  2. Log out and back in to start Hyprland via SDDM"
echo "  3. Install oh-my-zsh:"
echo '       sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
echo "  4. Copy wallpapers to ~/Pictures/wallpapers"
