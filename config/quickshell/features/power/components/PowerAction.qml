import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string symbol: "󰐥"
    property color accent: "#62B6FF"

    signal activated

    implicitHeight: 100
    radius: 18
    clip: true

    readonly property bool hovered: mouse.containsMouse

    color: hovered ? "#25334D" : "#202B42"
    border.color: hovered ? accent : Qt.alpha(accent, 0.55)
    border.width: 1

    transform: Translate {
        y: root.hovered && !mouse.pressed ? -3 : 0
        Behavior on y {
            NumberAnimation {
                duration: 190
                easing.type: Easing.OutCubic
            }
        }
    }

    scale: mouse.pressed ? 0.975 : hovered ? 1.012 : 1

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 180
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 180
        }
    }

    // Nền gradient theo màu từng nút
    Rectangle {
        anchors.fill: parent
        radius: parent.radius

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0
                color: Qt.alpha(root.accent, root.hovered ? 0.24 : 0.12)
            }

            GradientStop {
                position: 0.55
                color: Qt.alpha(root.accent, 0.045)
            }

            GradientStop {
                position: 1
                color: "transparent"
            }
        }
    }

    // Dải sáng mảnh bên trái
    Rectangle {
        width: 3
        height: root.hovered ? 46 : 26
        radius: 2

        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.verticalCenter: parent.verticalCenter

        color: root.accent
        opacity: root.hovered ? 0.95 : 0.35

        Behavior on height {
            NumberAnimation {
                duration: 180
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 22
        spacing: 18

        // ICON
        Rectangle {
            radius: 18
            color: Qt.alpha(root.accent, root.hovered ? 0.18 : 0.08)
            border.color: Qt.alpha(root.accent, root.hovered ? 0.4 : 0.15)
            Behavior on color {
                ColorAnimation {
                    duration: 180
                }
            }
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56

            Text {
                anchors.centerIn: parent
                text: root.symbol
                color: root.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 38

                scale: root.hovered ? 1.12 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutBack
                    }
                }
            }
        }

        // TÊN + MÔ TẢ
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 7

            Text {
                Layout.fillWidth: true
                text: root.title
                color: "#FFFFFF"
                font.pixelSize: 17
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: "#B2C3DF"
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.activated()
    }
}
