
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p config packages home local/bin

# Các thư mục cấu hình cần sao lưu
configs=(
    hypr
    quickshell
    fcitx5
    waybar
    wofi
    kitty
    hyprpaper
    rofi
    swaync
    mako
    dunst
    gtk-3.0
    gtk-4.0
    qt5ct
    qt6ct
    Kvantum
    fastfetch
    btop
    fontconfig
    environment.d
    systemd/user
)

echo "=== BACKUP CONFIG ==="

for name in "${configs[@]}"; do
    src="$HOME/.config/$name"
    dest="config/$name"

    if [[ -d "$src" ]]; then
        mkdir -p "$dest"

        rsync -a --delete \
            --exclude='.env' \
            --exclude='.env.*' \
            --exclude='*.pem' \
            --exclude='*.key' \
            --exclude='*secret*' \
            --exclude='*token*' \
            --exclude='*credential*' \
            "$src/" "$dest/"

        echo "[OK] $name"
    fi
done

echo "=== BACKUP TERMINAL ==="

for file in .bashrc .zshrc .zprofile .profile; do
    if [[ -f "$HOME/$file" ]]; then
        cp -p "$HOME/$file" "home/$file"
    fi
done

# Script tự viết
if [[ -d "$HOME/.local/bin" ]]; then
    rsync -a \
        --exclude='*.key' \
        --exclude='*.pem' \
        --exclude='.env' \
        "$HOME/.local/bin/" local/bin/
fi

echo "=== BACKUP PACKAGE LIST ==="

pacman -Qqen | sort -u > packages/pacman.txt
pacman -Qqem | sort -u > packages/foreign.txt

echo "=== HOAN TAT ==="
du -sh config packages home local/bin
