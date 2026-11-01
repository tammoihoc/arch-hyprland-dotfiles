#!/usr/bin/env bash
# Arch Linux / Hyprland / Quickshell restore from this repository.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.local/state/arch-hyprland-installer"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
trap 'echo "[LỖI] Dừng ở dòng $LINENO. Xem log: $LOG_FILE" >&2' ERR

if ((EUID == 0)); then
  echo 'Không chạy install.sh bằng sudo. Hãy chạy ./install.sh; script sẽ tự xin sudo.' >&2
  exit 1
fi
if [[ ! -f /etc/arch-release ]]; then
  echo 'Script chỉ hỗ trợ Arch Linux.' >&2
  exit 1
fi
for cmd in sudo pacman git python3 rsync; do
  command -v "$cmd" >/dev/null || {
    echo "Thiếu $cmd; cài trước: sudo pacman -S --needed git python rsync sudo" >&2
    exit 1
  }
done
[[ -f "$ROOT/config/hypr/hyprland.lua" && -f "$ROOT/config/quickshell/shell.qml" ]] || {
  echo 'Repo thiếu config/hypr/hyprland.lua hoặc config/quickshell/shell.qml' >&2
  exit 1
}

printf '
=== Cài Hyprland + Quickshell cho %s ===
' "$(id -un)"
printf 'Thư mục home: %s
Log: %s
' "$HOME" "$LOG_FILE"
echo 'Script không phân vùng ổ đĩa, không chỉnh GRUB và không khởi động lại máy.'

# Only the packages used by the supplied QML/Lua plus useful desktop dependencies.
PACMAN=(
  base-devel git go python rsync sudo
  hyprland hyprpaper xorg-xwayland xdg-desktop-portal-hyprland
  kitty dolphin wofi code
  networkmanager bluez bluez-utils fcitx5 fcitx5-unikey fcitx5-qt fcitx5-gtk fcitx5-configtool
  pipewire pipewire-alsa pipewire-pulse wireplumber
  brightnessctl playerctl grim satty wl-clipboard
  qt6-wayland qt6-5compat
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols noto-fonts-cjk
  papirus-icon-theme
  upower power-profiles-daemon polkit-kde-agent gvfs tumbler thunar-archive-plugin ffmpegthumbnailer
  greetd cage
  dbus
)

echo '[1/6] Yêu cầu mật khẩu sudo khi cần...'
sudo -v
echo '[2/6] Đồng bộ và cài gói pacman...'
sudo pacman -Syu --needed "${PACMAN[@]}"

echo '[3/6] Cài Quickshell từ AUR (quickshell-git, đúng bản bạn đang dùng)...'
if ! pacman -Q quickshell-git >/dev/null 2>&1; then
  if ! command -v yay >/dev/null 2>&1; then
    tmpdir="$(mktemp -d)"
    trap 'rm -rf -- "${tmpdir:-}"' EXIT
    git clone --depth 1 https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --needed --noconfirm)
    rm -rf -- "$tmpdir"
    trap - EXIT
  fi
  yay -S --needed --noconfirm quickshell-git
fi

# Back up the current configuration, then copy rather than symlink: greetd's deployment
# scripts expect the source files to be in ~/.config/quickshell.
echo '[4/6] Sao lưu và khôi phục dotfiles...'
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.local/state/arch-hyprland-installer/backup-$STAMP"
mkdir -p "$BACKUP" "$HOME/.config/hypr" "$HOME/.config/quickshell" "$HOME/Pictures"
if [[ -f "$HOME/.config/hypr/hyprland.lua" ]]; then
  cp -a "$HOME/.config/hypr/hyprland.lua" "$BACKUP/hyprland.lua"
fi
if [[ -d "$HOME/.config/quickshell" ]]; then
  cp -a "$HOME/.config/quickshell" "$BACKUP/quickshell"
fi
rsync -a "$ROOT/config/quickshell/" "$HOME/.config/quickshell/"
cp -a "$ROOT/config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
# Khôi phục Kitty
if [[ -f "$ROOT/config/kitty/kitty.conf" ]]; then
  mkdir -p "$HOME/.config/kitty"

  if [[ -f "$HOME/.config/kitty/kitty.conf" ]]; then
    cp -a "$HOME/.config/kitty/kitty.conf" "$BACKUP/kitty.conf"
  fi

  cp -a "$ROOT/config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
fi

# Khôi phục Bash
if [[ -f "$ROOT/home/.bashrc" ]]; then
  if [[ -f "$HOME/.bashrc" ]]; then
    cp -a "$HOME/.bashrc" "$BACKUP/bashrc"
  fi

  cp -a "$ROOT/home/.bashrc" "$HOME/.bashrc"
fi
if [[ -d "$ROOT/Pictures" ]]; then
  rsync -a --exclude='README.txt' "$ROOT/Pictures/" "$HOME/Pictures/"
fi
chmod +x "$HOME/.config/quickshell/lock/lock.sh" "$HOME/.config/quickshell/lock/scripts/"*.sh

# Rebase only known absolute paths and the two greeter account references.
# Keep the existing QML import syntax and all visual code unchanged.
CURRENT_HOME="$HOME" CURRENT_USER="$(id -un)" python3 - <<'PY_REBASE'
import os, pathlib, re
home=pathlib.Path(os.environ['CURRENT_HOME'])
user=os.environ['CURRENT_USER']
files=[
  home/'.config/hypr/hyprland.lua',
  home/'.config/quickshell/features/power/theme/PowerTheme.qml',
  home/'.config/quickshell/lock/LockSettings.qml',
]
for p in files:
    text=p.read_text()
    text=re.sub(r'/home/(?:tam|tam123)(?=/)', str(home), text)
    p.write_text(text)
p=home/'.config/quickshell/lock/greeter.qml'
s=p.read_text()
s=re.sub(r'Greetd\.createSession\("(?:tam|tam123)"\)',
         lambda m: 'Greetd.createSession("'+user+'")', s)
s=re.sub(r'accountName:\s*"(?:tam|tam123)"',
         lambda m: 'accountName: "'+user+'"', s)
p.write_text(s)
PY_REBASE

# Enable the services necessary for the QML stats and the login manager.
echo '[5/6] Bật dịch vụ mạng và âm thanh...'
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service power-profiles-daemon.service
# The user audio services are socket activated; do not require a running graphical session.
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || echo 'Lưu ý: user services sẽ được kích hoạt trong phiên đăng nhập tiếp theo.'

# Don't enable greetd until the three referenced image assets are actually present.
echo '[6/6] Cài màn hình đăng nhập Quickshell (nếu đã đủ ảnh)...'
required=(
  "$HOME/Pictures/anhvabe.jpeg"
  "$HOME/Pictures/be.jpeg"
  "$HOME/Pictures/kingdom-hearts-3840x2160-27569.jpg"
)
missing=()
for file in "${required[@]}"; do [[ -f "$file" ]] || missing+=("$file"); done
if ((${#missing[@]} > 0)); then
  printf '[CHƯA CÀI GREETER] Thiếu ảnh:
'
  printf '  %s
' "${missing[@]}"
  echo 'Hãy thêm Pictures vào repo, chạy lại ./install.sh để tự cài greetd.'
else
  # Existing installer refuses to overwrite another display manager.
  sudo bash "$HOME/.config/quickshell/lock/scripts/install-greeter.sh"
fi

echo
echo 'Đã cài gói và chép dotfiles. Không tự reboot.'
echo "Backup: $BACKUP"
echo "Log: $LOG_FILE"
echo 'Lưu ý: chưa kiểm tra PAM mở khóa trên máy cài mới; hãy thử preview và xác thực an toàn trước khi phụ thuộc vào màn hình khóa.'
