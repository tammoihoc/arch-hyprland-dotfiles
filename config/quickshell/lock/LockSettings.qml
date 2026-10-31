import QtQuick
import "file:///home/tam/.config/quickshell/features/power/theme" as Theme

QtObject {
    readonly property Theme.PowerTheme sharedTheme: Theme.PowerTheme {}
    // Dùng chung ảnh với menu nguồn; đường dẫn trống dùng nền xanh tối.
    property url wallpaper: sharedTheme.bannerPath ? "file://" + sharedTheme.bannerPath : ""
    property url avatar: sharedTheme.avatarPath ? "file://" + sharedTheme.avatarPath : ""
    property string displayName: "Thành Tâm"
    property string motto: ""
}
