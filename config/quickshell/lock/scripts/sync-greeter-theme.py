#!/usr/bin/env python3
"""Deploy the greeter UI and a readable snapshot of PowerTheme's images."""
from pathlib import Path
import json
import re
import shutil
import sys

source = Path(__file__).resolve().parents[1]
target = Path(sys.argv[1])
theme = (source.parent / 'features/power/theme/PowerTheme.qml').read_text()
images = {}
for key in ('avatarPath', 'bannerPath'):
    pattern = rf'(property string {key}:\s*)("(?:[^"\\]|\\.)*")'
    match = re.search(pattern, theme)
    if not match:
        raise SystemExit(f'Không đọc được {key} trong PowerTheme.qml')
    value = json.loads(match[2])
    if not value:
        continue
    image = Path(value)
    if not image.is_absolute() or not image.is_file():
        raise SystemExit(f'Không tìm thấy ảnh {key}: {value}')
    images[key] = image

for folder in ('', 'assets', 'theme', 'components', 'music'):
    directory = target / folder
    directory.mkdir(parents=True, exist_ok=True)
    directory.chmod(0o755)
for key, image in images.items():
    dest = target / 'assets' / (key + image.suffix)
    shutil.copyfile(image, dest)
    dest.chmod(0o644)
    pattern = rf'(property string {key}:\s*)("(?:[^"\\]|\\.)*")'
    theme = re.sub(pattern, lambda m: m[1] + json.dumps(str(dest)), theme)

files = ['greeter.qml', 'LockView.qml', 'LockButton.qml', 'LockStats.qml', 'LockSettings.qml']
files += [str(p.relative_to(source)) for folder in ('components', 'music')
          for p in (source / folder).glob('*.qml')]
for name in files:
    content = (source / name).read_text()
    if name == 'LockSettings.qml':
        content = content.replace('"file:///home/tam/.config/quickshell/features/power/theme"', '"theme"')
    dest = target / name
    dest.write_text(content)
    dest.chmod(0o644)
dest = target / 'theme/PowerTheme.qml'
dest.write_text(theme)
dest.chmod(0o644)
print(f'Đã đồng bộ giao diện và ảnh PowerTheme vào {target}')
