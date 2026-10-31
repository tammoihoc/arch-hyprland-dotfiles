# ===== History configuration =====
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# Chia sẻ history giữa các tab/session đang chạy
setopt share_history

# Ghi lệnh vào file ngay lập tức (không đợi thoát shell)
setopt inc_append_history

# Bỏ qua lệnh trùng lặp liên tiếp
setopt hist_ignore_dups

# Bỏ qua lệnh bắt đầu bằng dấu cách (nếu muốn giấu lệnh nhạy cảm)
setopt hist_ignore_space

# Xóa lệnh trùng ở các vị trí cũ, giữ vị trí mới nhất
setopt hist_ignore_all_dups

# Chia sẻ lệnh ngay khi gõ, không đợi đến khi chạy xong
setopt hist_reduce_blanks

# Added by the Postman CLI installer
export PATH='/home/tam/.local/bin':"$PATH"
export PATH="$HOME/development/flutter/bin:$PATH"
export ANDROID_HOME=/opt/android-sdk
export ANDROID_HOME=/opt/android-sdk
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
