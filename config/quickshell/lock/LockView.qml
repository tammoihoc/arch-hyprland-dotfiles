import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import "./components" as Shared
import "./music" as Music

Item {
    id: root
    property bool loginMode: false
    property string accountName: Quickshell.env("USER") || "user"
    property bool busy: false
    property string errorMessage: ""
    property string prompt: "Nhập mật khẩu…"
    property bool preview: false
    property bool revealed: false
    property string pendingAction: ""
    signal submitted(string password)
    signal actionRequested(string action)
    function clearPassword() {
        password.text = "";
    }
    LockSettings {
        id: settings
    }
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    Component.onCompleted: {
        revealed = true;
        password.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: "#111323"
            }
            GradientStop {
                position: 0.52
                color: "#172A47"
            }
            GradientStop {
                position: 1
                color: "#0C1728"
            }
        }
    }
    Image {
        anchors.fill: parent
        source: settings.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: "#B8050912"
            }
            GradientStop {
                position: 0.52
                color: "#40050912"
            }
            GradientStop {
                position: 1
                color: "#70050912"
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#10060912"
            }
            GradientStop {
                position: 0.65
                color: "#00060912"
            }
            GradientStop {
                position: 1
                color: "#B0060912"
            }
        }
    }

    // Coordinates follow the reference; scale down uniformly on smaller monitors.
    Item {
        id: canvas
        width: 1672
        height: 941
        anchors.centerIn: parent
        scale: Math.min(root.width / width, root.height / height)
        opacity: root.revealed ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 380
                easing.type: Easing.OutCubic
            }
        }
        transform: Translate {
            y: root.revealed ? 0 : 20
            Behavior on y {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            id: timeText
            x: 140
            y: 130
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: 108
            font.weight: Font.Bold
            font.family: "DejaVu Sans"
            color: "#B9C8FF"
            visible: true
        }
        OpacityMask {
            x: timeText.x
            y: timeText.y
            width: timeText.width
            height: timeText.height
            source: clockGradient
            maskSource: timeText
        }
        // A gradient mask keeps the clock readable over any wallpaper.
        Rectangle {
            id: clockGradient
            x: timeText.x
            y: timeText.y
            width: timeText.width
            height: timeText.height
            visible: false
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0
                    color: "#F0C9F7"
                }
                GradientStop {
                    position: 1
                    color: "#67BAFF"
                }
            }
        }
        Text {
            x: 142
            y: 257
            text: clock.date.toLocaleDateString(Qt.locale("vi_VN"), "dddd, d 'tháng' M, yyyy")
            color: "#E0E7FA"
            font.pixelSize: 23
        }

        Rectangle {
            x: 142
            y: 325
            width: 160
            height: 160
            radius: 28
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0
                    color: "#75D6FF"
                }
                GradientStop {
                    position: 0.5
                    color: "#D9ADFF"
                }
                GradientStop {
                    position: 1
                    color: "#6EA9FF"
                }
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 26
                color: "#162039"
                Text {
                    anchors.centerIn: parent
                    text: "T"
                    font.pixelSize: 64
                    color: "#A8C8FF"
                }
                Shared.PowerRoundedImage {
                    anchors.fill: parent
                    source: settings.avatar
                    cornerRadius: 26
                }
            }
        }
        Column {
            x: 332
            y: 333
            spacing: 11
            Text {
                text: settings.displayName
                color: "#F2F4FF"
                font.pixelSize: 32
                font.bold: true
            }
            Text {
                text: "@" + root.accountName
                color: "#BAC8E6"
                font.pixelSize: 22
            }
            Text {
                text: root.loginMode ? "●  Đăng nhập · Hyprland" : "●  Đã khóa · Hyprland"
                color: "#35DFAB"
                font.pixelSize: 16
            }
            Text {
                text: settings.motto
                color: "#CFD8EB"
                font.pixelSize: 16
                font.italic: true
            }
        }

        Rectangle {
            x: 141
            y: 515
            width: 570
            height: 76
            radius: 25
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0
                    color: root.errorMessage ? "#FF718E" : "#70CCFF"
                }
                GradientStop {
                    position: 0.55
                    color: "#C6A4FF"
                }
                GradientStop {
                    position: 1
                    color: "#7B9EFF"
                }
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 23
                color: "#EC172035"
            }
            Text {
                x: 23
                anchors.verticalCenter: parent.verticalCenter
                text: "󰌾"
                color: "#88ADFF"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 27
            }
            TextInput {
                id: password
                x: 68
                anchors.verticalCenter: parent.verticalCenter
                width: 420
                height: 38
                verticalAlignment: TextInput.AlignVCenter
                color: "#F0F4FF"
                font.pixelSize: 19
                echoMode: TextInput.Password
                passwordCharacter: "●"
                selectionColor: "#5476AB"
                clip: true
                enabled: !root.busy
                focus: true
                inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                onAccepted: root.submit()
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: password.text.length === 0
                    text: root.busy ? "Đang xác thực…" : root.prompt
                    color: "#899BBD"
                    font.pixelSize: 18
                }
            }
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 48
                radius: 24
                color: unlockMouse.containsMouse ? "#4768A1" : "#253D65"
                border.color: "#8FB4FF"
                border.width: 2
                scale: unlockMouse.pressed ? 0.91 : 1
                Behavior on scale {
                    NumberAnimation {
                        duration: 120
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: "→"
                    color: "#C7DDFF"
                    font.pixelSize: 30
                }
                MouseArea {
                    id: unlockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !root.busy
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.submit()
                }
            }
        }
        Text {
            x: 154
            y: 593
            text: root.errorMessage
            color: "#FF9DAF"
            font.pixelSize: 13
        }
        Row {
            x: 141
            y: 619
            spacing: 24
            LockButton {
                symbol: "󰐥"
                label: "Tắt máy"
                accent: "#FF637F"
                onActivated: root.pendingAction = "shutdown"
            }
            LockButton {
                symbol: "󰜉"
                label: "Khởi động lại"
                accent: "#36E9BC"
                onActivated: root.pendingAction = "restart"
            }
            LockButton {
                symbol: "󰤄"
                label: "Chế độ Ngủ"
                accent: "#B692FF"
                onActivated: root.actionRequested("sleep")
            }
            LockButton {
                symbol: "󰍃"
                visible: !root.loginMode
                label: "Đăng xuất"
                accent: "#FFB344"
                onActivated: root.pendingAction = "logout"
            }
        }
        LockStats {
            x: 141
            y: 768
        }
        Music.PowerMusic {
            visible: !root.loginMode
            x: 884
            y: 617
            width: 730
            height: 230
            opacity: 0.94
        }
        Text {
            x: 142
            y: 857
            text: root.preview ? "XEM TRƯỚC · Esc để đóng" : root.loginMode ? "Nhập mật khẩu và nhấn Enter để đăng nhập" : "Nhập mật khẩu và nhấn Enter để mở khóa"
            color: "#8291AE"
            font.pixelSize: 12
            font.letterSpacing: 0.6
        }
        Rectangle {
            anchors.fill: parent
            color: "#D908101E"
            visible: root.pendingAction !== ""
            MouseArea {
                anchors.fill: parent
                onClicked: root.pendingAction = ""
            }
            Rectangle {
                anchors.centerIn: parent
                width: 480
                height: 224
                radius: 28
                color: "#19233A"
                border.color: "#6E8BB9"
                MouseArea {
                    anchors.fill: parent
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 24
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Xác nhận " + ({
                                shutdown: "tắt máy",
                                restart: "khởi động lại",
                                logout: "đăng xuất"
                            }[root.pendingAction] || "") + "?"
                        color: "#EDF2FF"
                        font.pixelSize: 23
                    }
                    Text {
                        text: "Công việc chưa lưu có thể bị mất."
                        color: "#A9B8D5"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 15
                    }
                    Row {
                        spacing: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        Rectangle {
                            width: 160
                            height: 44
                            radius: 14
                            color: "#2B3A56"
                            Text {
                                anchors.centerIn: parent
                                text: "Hủy"
                                color: "white"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.pendingAction = ""
                            }
                        }
                        Rectangle {
                            width: 160
                            height: 44
                            radius: 14
                            color: "#A8BCFF"
                            Text {
                                anchors.centerIn: parent
                                text: "Xác nhận"
                                color: "#10182B"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    const action = root.pendingAction;
                                    root.pendingAction = "";
                                    root.actionRequested(action);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    function submit() {
        if (!root.busy && password.text.length > 0) {
            root.submitted(password.text);
            password.text = "";
            password.forceActiveFocus();
        }
    }
}
