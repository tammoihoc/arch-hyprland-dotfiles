#!/usr/bin/env bash
set -euo pipefail
if (( EUID != 0 )); then
    echo 'Cần sudo để cập nhật giao diện đăng nhập trong /usr/local/share và /etc/greetd.' >&2
    exit 1
fi
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
# Validate the installed setup before touching system files.
python3 - <<'PY'
from pathlib import Path
import tomllib
p = Path('/etc/greetd/config.toml')
s = p.read_text()
c = tomllib.loads(s)
expected = '/usr/local/share/tam-greeter/greeter.qml'
if expected not in c.get('default_session', {}).get('command', ''):
    raise SystemExit('Cấu hình greetd khác dự kiến; chưa thay đổi.')
old = 'dbus-run-session cage -s -- /usr/bin/quickshell -p ' + expected
new = 'dbus-run-session cage -s -d -- env QT_WAYLAND_DISABLE_WINDOWDECORATION=1 /usr/bin/quickshell -p ' + expected
if c['default_session']['command'] not in (old, new):
    raise SystemExit('Lệnh greetd đã được tùy chỉnh; chưa thay đổi.')
updated = s.replace(old, new)
tomllib.loads(updated)
p.write_text(updated)
PY
python3 "$source_dir/scripts/sync-greeter-theme.py" /usr/local/share/tam-greeter
printf '\nĐã cập nhật màn hình đăng nhập: toàn màn hình, dùng chung ảnh đại diện và nền từ PowerTheme.\nCó hiệu lực lần đăng xuất hoặc khởi động lại kế tiếp. Không restart phiên hiện tại.\n'
