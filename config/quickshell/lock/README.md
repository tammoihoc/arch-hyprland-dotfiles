# Màn hình khóa Quickshell · Hyprland Lua

Giao diện theo ảnh tham khảo: đồng hồ gradient, ngày tiếng Việt, hồ sơ,
ô mật khẩu, các nút nguồn, thống kê CPU/RAM/pin và trình phát MPRIS.
Ảnh đại diện và nền dùng chung với menu Power.

## Sử dụng

- `Super + L`: khóa phiên.
- Menu Power → Khóa màn hình: dùng cùng màn hình khóa.
- Menu Power → Chế độ Ngủ: khóa, đợi Wayland xác nhận rồi suspend.
- `loginctl lock-session`: cũng được daemon nhận qua D-Bus đúng phiên hiện tại.
- Mở khóa: mật khẩu tài khoản Linux hiện tại, Enter hoặc nút mũi tên.
- Các nút tắt máy, khởi động lại và đăng xuất có xác nhận.

Xem trước (không khóa máy, không xác thực và không thực thi các nút nguồn):

```sh
~/.config/quickshell/lock/lock.sh preview
```

Đóng cửa sổ hoặc Esc để thoát xem trước.

## Ảnh đại diện và ảnh nền

Sửa `avatarPath` và `bannerPath` trong
`~/.config/quickshell/features/power/theme/PowerTheme.qml` (đường dẫn tuyệt đối).
Màn hình khóa và bản xem trước đăng nhập đọc chung hai thuộc tính này.
`LockSettings.qml` vẫn chứa `displayName` và `motto`.
Ảnh nền phủ kín màn hình, giữ tỉ lệ và có lớp tối giúp chữ dễ đọc.
Khi đang khóa, tạm ngừng tải lại cấu hình để giữ phiên khóa ổn định.

Bản đăng nhập hệ thống dùng bản sao ảnh để tài khoản `greeter` không cần
truy cập thư mục nhà. Sau khi đổi ảnh, đồng bộ bằng:

```sh
sudo ~/.config/quickshell/lock/scripts/update-greeter-window.sh
```

## Tích hợp

- `hypr/hyprland.lua`: phím Super + L và autostart `lock.sh daemon` (không khóa lại sau đăng nhập).
- `quickshell/features/power/PowerMenu.qml`: gọi `lock.sh` / `lock.sh sleep`.
- Daemon khóa riêng với thanh bar, IPC chỉ có `lock` và `sleep`, không có unlock.
- `WlSessionLock` tạo bề mặt khóa trên mọi màn hình. Chỉ nhả khóa sau
  `PamResult.Success`; Esc không mở khóa.
- `pam/lock` include tuyệt đối `/etc/pam.d/system-auth`, giữ chính sách
  xác thực của máy. Không sửa PAM hệ thống, không lưu mật khẩu vào file/log.
- Bố cục co đồng đều theo kích thước màn hình. Nhạc và thống kê là dữ liệu thật;
  sóng nhạc là hiệu ứng trang trí, không phải phổ âm thanh.

## Kiểm tra đã thực hiện

- `qmllint` cho view, nút, thống kê, daemon và preview: không cảnh báo.
- `luac -p` và `sh -n`: hợp lệ.
- `hyprctl reload` và `hyprctl configerrors`: không lỗi; đã thấy bind Super + L.
- Chạy preview thực tế trên Wayland, chụp và xem bố cục.
- Daemon tải thành công, IPC nhận đúng hai hàm, D-Bus monitor chạy đúng phiên.
- Chưa thử khóa/mở khóa bằng mật khẩu thật hoặc thực thi nút nguồn, để không
  gián đoạn phiên làm việc đang dùng.

## Tiến trình riêng và Kitty

Phần khóa nằm trong `quickshell/lock/` nhưng vẫn chạy thành tiến trình riêng.
Thanh bar dùng `quickshell/shell.qml`; màn hình khóa dùng `quickshell/lock/shell.qml`.

Xem log của daemon trong Kitty:

```sh
kitty --hold quickshell log -p ~/.config/quickshell/lock/shell.qml --follow
```

Xem trước giao diện từ Kitty:

```sh
kitty --hold ~/.config/quickshell/lock/lock.sh preview
```

Chỉ restart daemon khi đang mở khóa:

```sh
quickshell kill -p ~/.config/quickshell/lock/shell.qml
~/.config/quickshell/lock/lock.sh daemon
```

## Màn hình đăng nhập trước desktop

`greeter.qml` dùng Quickshell.Services.Greetd. Greetd xác thực tài khoản `tam`
với PAM hệ thống; chỉ tín hiệu `readyToLaunch` mới khởi chạy `start-hyprland`.
Giao diện chạy dưới tài khoản dịch vụ `greeter`, không đăng nhập tài khoản `tam`.
Cấu hình chỉ có `default_session`, hoàn toàn không có `initial_session`.
Trước đăng nhập không hiển thị nhạc của phiên cá nhân và không có nút đăng xuất.

Cài đặt (cần nhập mật khẩu sudo trực tiếp trong terminal):

```sh
sudo ~/.config/quickshell/lock/scripts/install-greeter.sh
```

Script cài gói `greetd`, `cage`, sao chép UI và ảnh đã chọn vào
`/usr/local/share/tam-greeter/`, cấu hình `/etc/greetd/config.toml`, rồi enable
`greetd.service` cho lần khởi động kế tiếp. Không dùng `--now`, không đăng xuất
hoặc khởi động lại máy. Cấu hình greetd cũ được lưu trong `/var/backups/tam-greeter/`.
Sau khi thay đổi ảnh/UI, chạy lại script để cập nhật bản hệ thống.

Xem trước màn hình đăng nhập (không đăng nhập thật):

```sh
GREETER_PREVIEW=1 quickshell -p ~/.config/quickshell/lock/greeter.qml
```

Đã kiểm tra cú pháp QML, Lua, Bash và chạy greeter ở chế độ preview.
Cài đặt hệ thống và đăng nhập greetd thật cần quyền sudo và chưa được xác nhận.

## Hiển thị toàn màn hình, không nút cửa sổ

Greeter dùng Qt Window với `Window.FullScreen` và `Qt.FramelessWindowHint`.
Cage chạy với `-d` và biến `QT_WAYLAND_DISABLE_WINDOWDECORATION=1` chỉ dành
cho tiến trình greeter. Preview dùng cùng cửa sổ không viền, Esc để thoát.
Cập nhật giao diện và đồng bộ ảnh từ PowerTheme cho bản đã cài:

```sh
sudo ~/.config/quickshell/lock/scripts/update-greeter-window.sh
```

Không restart greetd trong phiên đang dùng. Bản cập nhật có hiệu lực lần
đăng xuất hoặc khởi động tiếp theo.
