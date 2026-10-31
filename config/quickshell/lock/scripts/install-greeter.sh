#!/usr/bin/env bash
set -euo pipefail
if (( EUID != 0 )); then
    echo 'Chạy bằng sudo trong terminal để cài màn hình đăng nhập hệ thống.' >&2
    exit 1
fi
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
target_dir=/usr/local/share/tam-greeter
# Fail before changing the boot login if another display manager is configured.
if [[ -L /etc/systemd/system/display-manager.service ]]; then
    active_manager=$(readlink -f /etc/systemd/system/display-manager.service)
    if [[ $active_manager != */greetd.service ]]; then
        echo "Đã có display manager: $active_manager. Chưa thay đổi cấu hình." >&2
        exit 1
    fi
fi
/usr/bin/pacman -S --needed --noconfirm greetd cage
getent passwd greeter >/dev/null || { echo 'Thiếu tài khoản dịch vụ greeter từ gói greetd.' >&2; exit 1; }
python3 "$source_dir/scripts/sync-greeter-theme.py" "$target_dir"
install -d -m 0755 /etc/greetd
if [[ -f /etc/greetd/config.toml ]]; then
    install -d -m 0700 /var/backups/tam-greeter
    cp -a /etc/greetd/config.toml "/var/backups/tam-greeter/config.$(date +%Y%m%d-%H%M%S).toml"
fi
# No initial_session: tam is never automatically logged in.
cat > /etc/greetd/config.toml <<'TOML'
[terminal]
vt = 1

[default_session]
command = "dbus-run-session cage -s -d -- env QT_WAYLAND_DISABLE_WINDOWDECORATION=1 /usr/bin/quickshell -p /usr/local/share/tam-greeter/greeter.qml"
user = "greeter"
TOML
chmod 0644 /etc/greetd/config.toml
systemctl enable greetd.service
printf '\nĐã cài màn hình đăng nhập. Có hiệu lực lần khởi động máy kế tiếp.\nKhông bật tự động đăng nhập; không restart phiên đang dùng.\n'
