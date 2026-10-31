import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

RowLayout {
    id: workspaceBar
    spacing: 5

    // Lấy appClass của cửa sổ trong workspace
    function getAppClass(wsId) {
        const windows = Hyprland.toplevels.values

        for (let i = 0; i < windows.length; i++) {
            const win = windows[i]

            if (!win.workspace || win.workspace.id !== wsId)
                continue

            const cls = (
                win.lastIpcObject?.class ||
                win.wayland?.appId ||
                ""
            ).toLowerCase()

            if (cls.includes("chrome")) return "google-chrome"
            if (cls.includes("firefox")) return "firefox"
            if (cls.includes("kitty")) return "kitty"
            if (cls.includes("code")) return "visual-studio-code"
            if (cls.includes("thunar")) return "thunar"
            if (cls.includes("discord")) return "discord"
            if (cls.includes("spotify")) return "spotify"

            return cls
        }

        return ""
    }

    Repeater {
        model: 10

        Rectangle {
            id: wsItem

            required property int index
            readonly property int wsId: index + 1

            property bool isActive: {
                const monitor = Hyprland.focusedMonitor
                return monitor && monitor.activeWorkspace
                    && monitor.activeWorkspace.id === wsId
            }

            property string appClass: {
                let _count = Hyprland.toplevels.values.length
                return workspaceBar.getAppClass(wsId)
            }

            implicitWidth: isActive ? 38 : 30
            implicitHeight: 28
            radius: 8

            color: isActive ? "#313244" : "transparent"
            border.color: isActive ? "#89b4fa" : "transparent"
            border.width: 1

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                implicitSize: 18

                source: wsItem.appClass !== ""
                    ? Quickshell.iconPath(wsItem.appClass, "application-x-executable")
                    : ""

                visible: wsItem.appClass !== "" && status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: !appIcon.visible
                text: wsItem.wsId.toString()
                color: wsItem.isActive ? "#89b4fa" : "#6c7086"
                font.pixelSize: 12
                font.bold: wsItem.isActive
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    console.log("-> Switching workspace:", wsItem.wsId)

                    Hyprland.dispatch(
                        "hl.dsp.focus({ workspace = " + wsItem.wsId + " })"
                    )
                }
            }
        }
    }
}
