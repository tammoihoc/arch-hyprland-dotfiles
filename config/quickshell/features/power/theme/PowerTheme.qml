
import QtQuick
import Quickshell

QtObject {
    id: theme

    readonly property color background: "#F0121729"
    readonly property color card: "#D9222D46"
    readonly property color foreground: "#F4F7FF"
    readonly property color muted: "#A9B8D5"
    readonly property color borderColor: "#64769D"

    readonly property color blue: "#62B6FF"
    readonly property color purple: "#C58AFF"
    readonly property color orange: "#FFA66B"
    readonly property color green: "#48E6AD"
    readonly property color pink: "#FF789D"
    readonly property color cyan: "#52DFFF"

    // Để trống sẽ tự lấy username Linux
    property string customName: "Thành Tâm"
    readonly property string username: Quickshell.env("USER") || "user"
    readonly property string displayName:
        customName.length > 0 ? customName : username

    // Thay bằng ảnh thật của bạn
    property string avatarPath: "/home/tam/Pictures/8c52b476-dd15-418e-a8b9-5f3c8beb7552.jpeg"
    property string bannerPath: "/home/tam/Pictures/557f8523-0fd0-42cb-9757-59832d2f3d9c.jpeg"

    readonly property int animationDuration: 220
}
