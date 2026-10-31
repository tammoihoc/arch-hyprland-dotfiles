import QtQuick
import QtQuick.Layouts
import Quickshell
import "./components" as Components
import "./music" as Music
import "./theme" as Theme
import Quickshell.Wayland

Item {
    id: root

    implicitWidth: 32
    implicitHeight: 28
    Timer {
        id: openAnimation
        interval: 24
        onTriggered: root.openingAnimation = true
    }
    Timer {
        id: closeAnimation
        interval: 240
        onTriggered: {
            root.expanded = false;
            root.pendingAction = "";
        }
    }
    property bool expanded: false
    property string pendingAction: ""
    property bool openingAnimation: false
    Theme.PowerTheme {
        id: theme
    }

    function closeMenu() {
        openAnimation.stop();
        openingAnimation = false;
        closeAnimation.restart();
    }

    function selectAction(action) {
        pendingAction = action;
    }

    function actionTitle(action) {
        switch (action) {
        case "lock":
            return "khóa màn hình";
        case "sleep":
            return "chế độ ngủ";
        case "logout":
            return "đăng xuất";
        case "restart":
            return "khởi động lại";
        case "shutdown":
            return "tắt máy";
        default:
            return "";
        }
    }

    function actionIcon(action) {
        switch (action) {
        case "lock":
            return "󰌾";
        case "sleep":
            return "󰤄";
        case "logout":
            return "󰍃";
        case "restart":
            return "󰜉";
        case "shutdown":
            return "󰐥";
        default:
            return "󰐥";
        }
    }

    function actionColor(action) {
        switch (action) {
        case "lock":
            return theme.blue;
        case "sleep":
            return theme.purple;
        case "logout":
            return theme.orange;
        case "restart":
            return theme.green;
        case "shutdown":
            return theme.pink;
        default:
            return theme.blue;
        }
    }

    function executeAction(action) {
        closeMenu();

        if (action === "lock")
            Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/lock/lock.sh"]);
        else if (action === "sleep")
            Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/lock/lock.sh", "sleep"]);
        else if (action === "logout")
            Quickshell.execDetached(["loginctl", "terminate-user", Quickshell.env("USER")]);
        else if (action === "restart")
            Quickshell.execDetached(["systemctl", "reboot"]);
        else if (action === "shutdown")
            Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    // Nút nguồn trên thanh bar
    Rectangle {
        anchors.fill: parent
        radius: 8

        Behavior on color {
            ColorAnimation {
                duration: 180
            }
        }

        color: powerMouse.containsMouse || root.expanded ? "#6B3445" : "#313244"

        Text {
            anchors.fill: parent
            text: "⏻"
            color: theme.pink
            font.family: "DejaVu Sans"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            topPadding: -2
        }
        scale: powerMouse.pressed ? 0.88 : root.expanded ? 1.05 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 170
                easing.type: Easing.OutCubic
            }
        }
        MouseArea {
            id: powerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.expanded) {
                    root.closeMenu();
                } else {
                    closeAnimation.stop();
                    root.pendingAction = "";
                    root.openingAnimation = false;
                    root.expanded = true;
                    openAnimation.restart();
                }
            }
        }
    }

    PanelWindow {
        id: overlay
        visible: root.expanded
        color: "transparent"
        exclusiveZone: 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        Item {
            anchors.fill: parent
            focus: true

            Keys.onEscapePressed: {
                if (root.pendingAction !== "")
                    root.pendingAction = "";
                else
                    root.closeMenu();
            }

            Rectangle {
                anchors.fill: parent
                color: "#C4080C1B"
                opacity: root.openingAnimation ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 230
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.closeMenu()
                }
            }

            Rectangle {
                id: dialog
                opacity: root.openingAnimation ? 1 : 0
                scale: root.openingAnimation ? 1 : 0.955
                transform: Translate {
                    id: dialogSlide
                    y: root.openingAnimation ? 0 : 28

                    Behavior on y {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.OutCubic
                    }
                }
                width: Math.min(1120, parent.width - 40)
                height: Math.min(root.pendingAction === "" ? 660 : 400, parent.height - 40)

                anchors.centerIn: parent
                radius: 28
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#FA202940"
                    }
                    GradientStop {
                        position: 0.55
                        color: "#FA151C30"
                    }
                    GradientStop {
                        position: 1
                        color: "#FA101626"
                    }
                }
                border.color: "#65758FAF"
                border.width: 1
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 240
                        easing.type: Easing.OutCubic
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 14

                    opacity: root.pendingAction === "" ? 1 : 0
                    visible: opacity > 0.01
                    enabled: root.pendingAction === "" && root.openingAnimation
                    scale: root.pendingAction === "" ? 1 : 0.97
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 160
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 240
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Profile + CPU RAM PIN
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 168

                        Components.PowerProfile {
                            anchors.fill: parent
                            displayName: theme.displayName
                            username: theme.username
                            avatarPath: theme.avatarPath
                            bannerPath: theme.bannerPath
                        }

                        Components.PowerStats {
                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            width: 280
                            height: 146
                        }
                    }

                    // 5 NÚT NGUỒN
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 12
                        rowSpacing: 12

                        Components.PowerAction {
                            Layout.fillWidth: true
                            title: "Khóa màn hình"
                            subtitle: "Khóa phiên hiện tại"
                            symbol: "󰌾"
                            accent: theme.blue
                            onActivated: root.selectAction("lock")
                        }

                        Components.PowerAction {
                            Layout.fillWidth: true
                            title: "Chế độ Ngủ"
                            subtitle: "Đưa máy vào chế độ ngủ"
                            symbol: "󰤄"
                            accent: theme.purple
                            onActivated: root.selectAction("sleep")
                        }

                        Components.PowerAction {
                            Layout.fillWidth: true
                            title: "Đăng xuất"
                            subtitle: "Thoát phiên hiện tại"
                            symbol: "󰍃"
                            accent: theme.orange
                            onActivated: root.selectAction("logout")
                        }

                        Components.PowerAction {
                            Layout.fillWidth: true
                            title: "Khởi động lại"
                            subtitle: "Khởi động lại hệ thống"
                            symbol: "󰜉"
                            accent: theme.green
                            onActivated: root.selectAction("restart")
                        }

                        Components.PowerAction {
                            Layout.fillWidth: true
                            title: "Tắt máy"
                            subtitle: "Tắt nguồn hệ thống"
                            symbol: "󰐥"
                            accent: theme.pink
                            onActivated: root.selectAction("shutdown")
                        }
                    }

                    // MUSIC PLAYER
                    Music.PowerMusic {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 208
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }

                Components.PowerConfirm {
                    anchors.centerIn: parent
                    width: Math.min(480, parent.width - 40)
                    height: 300
                    opacity: root.pendingAction !== "" ? 1 : 0
                    visible: opacity > 0.01
                    enabled: root.pendingAction !== "" && root.openingAnimation
                    scale: root.pendingAction !== "" ? 1 : 0.94
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }

                    actionName: root.actionTitle(root.pendingAction)
                    symbol: root.actionIcon(root.pendingAction)
                    accent: root.actionColor(root.pendingAction)

                    onCancelled: root.pendingAction = ""
                    onAccepted: root.executeAction(root.pendingAction)
                }

                // Nút đóng
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    width: 38
                    height: 38
                    radius: 12
                    z: 20
                    scale: closeMouse.pressed ? 0.9 : 1
                    Behavior on scale {
                        NumberAnimation {
                            duration: 140
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                        }
                    }
                    color: closeMouse.containsMouse ? "#53617E" : "#34415D"

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: "white"
                        font.pixelSize: 27
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeMenu()
                    }
                }
            }
        }
    }
}
