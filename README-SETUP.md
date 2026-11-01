# Khôi phục Arch Linux: Hyprland Lua + Quickshell + Pictures

Bộ file này được dựng từ **quickshell.zip**, **hyprland.lua** và **dotfiles-report.txt** bạn gửi ngày 01/11/2026.
Không thay giao diện QML; chỉ cập nhật các đường dẫn home và tài khoản greetd lúc cài.

## Trên máy hiện tại: cập nhật repo

1. Sao chép nội dung bộ file này vào thư mục gốc repo `arch-hyprland-dotfiles`.
2. Chạy `chmod +x backup.sh install.sh && ./backup.sh` để lấy bản cấu hình mới nhất và **ảnh thật** từ `~/Pictures/`.
3. Xem `git status`, `git diff` và rà soát thông tin cá nhân. Sau đó `git add . && git commit -m "Update Hyprland and Quickshell" && git push`.

**Cần có** `Pictures/anhvabe.jpeg`, `Pictures/be.jpeg`, `Pictures/kingdom-hearts-3840x2160-27569.jpg` trong repo để greeter hoạt động.
Hiện bộ ZIP này chưa chứa ảnh thật vì người dùng chưa tải thư mục Pictures lên cuộc trò chuyện.

## Sau khi cài Arch tối thiểu

- Có mạng, tài khoản người dùng bình thường có quyền sudo; bootloader và ổ đĩa đã cấu hình.
- `sudo pacman -Syu --needed git python rsync sudo`
- `git clone https://github.com/tammoihoc/arch-hyprland-dotfiles.git`
- `cd arch-hyprland-dotfiles && chmod +x install.sh && ./install.sh`

Script cài pacman và AUR `quickshell-git` (dựng `yay` nếu cần), chép cấu hình, sửa các đường dẫn cũ và tài khoản greetd, bật NetworkManager, âm thanh user và cài greeter qua script của bạn.
Greetd chỉ được cấu hình khi đủ ảnh; sẽ từ chối ghi đè display manager khác. Không tự restart, reboot, thay bootloader hoặc sửa PAM.

## Những điểm chưa tự động hóa

- Không cài tất cả các gói phát triển trong báo cáo (Docker, Java, VS Code, Chrome, NVIDIA...) vì không bắt buộc cho Hyprland/Quickshell; có thể bổ sung sau.
- `hyprland.lua` gọi `dolphin` (đã được thêm vào gói cài) và khai báo `hyprlauncher` (biến này chưa được sử dụng); `Super+R` thực tế dùng `wofi`.
- StartMenu có nút Antigravity nhưng không thấy gói cài tương ứng trong báo cáo.
- Cấu hình màn hình khóa PAM trong bản tải lên chưa được xác minh mở khóa thành công trên bản cài mới. Nên thử an toàn trước khi dùng thực tế.
- `hyprland.lua` đang cố định `1920x1080@144` và scale `1.25`; khi dùng màn hình khác có thể cần chỉnh.
- Repo GitHub **private** cần xác thực GitHub trước khi clone. Chỉ nhập mật khẩu sudo không thay thế bước này.

## Chú ý bảo mật

Thư mục `Pictures` có thể chứa ảnh riêng tư. Không chuyển repo sang public khi chưa kiểm tra.
Đọc `install.sh` và `scripts/install-greeter.sh` trước khi chạy với quyền sudo.
