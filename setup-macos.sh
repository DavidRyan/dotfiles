#!/bin/bash
# macOS Dotfiles Setup Script
# 1. Installs packages via install-packages.sh
# 2. Uses GNU Stow to symlink dotfiles

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"

# macOS-specific stow packages
MACOS_PACKAGES=(
    aerospace
    borders
    ghostty
    hammerspoon
    kitty
    nvim
    sketchybar
    zsh
)

# Packages that exist in the repo but are Linux-only
LINUX_ONLY=(
    colors
    hypr
    rofi
    waybar
)

echo "=============================="
echo "  macOS Dotfiles Setup"
echo "=============================="
echo ""
echo "Dotfiles dir: $DOTFILES_DIR"
echo "Target dir:   $TARGET_DIR"
echo ""

# ── Preflight checks ──────────────────────────────────────────────────────────

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only."
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
    echo "Install it manually: brew install stow"
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

for pkg in "${MACOS_PACKAGES[@]}"; do
    stow_package "$pkg"
done

# ── Complete ──────────────────────────────────────────────────────────────────

echo ""
echo "=============================="
echo "  Setup Complete!"
echo "=============================="
echo ""
echo "Stowed packages:"
for pkg in "${MACOS_PACKAGES[@]}"; do
    echo "  - $pkg"
done
echo ""
echo "Skipped (Linux-only):"
for pkg in "${LINUX_ONLY[@]}"; do
    echo "  - $pkg"
done
echo ""
echo "Next steps:"
echo "  1. Start aerospace:     open -a AeroSpace"
echo "  2. Start sketchybar:    brew services start sketchybar"
echo "  3. Start borders:       brew services start borders"
echo "  4. Enable Hammerspoon:  System Settings > Privacy > Accessibility"
echo "  5. Reload shell:        source ~/.zshrc"
