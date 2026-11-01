#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ${EUID} -eq 0 ]]; then echo 'Chạy bằng tài khoản thường, không dùng sudo.' >&2; exit 1; fi
for path in "$HOME/.config/quickshell" "$HOME/.config/hypr/hyprland.lua" "$HOME/Pictures"; do
    [[ -e "$path" ]] || { echo "Thiếu: $path" >&2; exit 1; }
done
command -v rsync >/dev/null || { echo 'Cần cài rsync: sudo pacman -S rsync' >&2; exit 1; }
mkdir -p "$ROOT/config/quickshell" "$ROOT/config/hypr" "$ROOT/Pictures"
rsync -a --exclude='*.qslog' --exclude='*.bak' "$HOME/.config/quickshell/" "$ROOT/config/quickshell/"
cp -a "$HOME/.config/hypr/hyprland.lua" "$ROOT/config/hypr/hyprland.lua"
rsync -a "$HOME/Pictures/" "$ROOT/Pictures/"
rm -f "$ROOT/Pictures/README.txt"
echo "Đã cập nhật Quickshell, hyprland.lua và Pictures vào: $ROOT"
echo 'Kiểm tra git diff và dữ liệu cá nhân trước khi git push.'
