
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string symbol: ""
    property color accent: "#62B6FF"

    signal activated()

    implicitHeight: 108
    radius: 16
    clip: true

    property bool hovered: mouse.containsMouse

    color: "#1B263D"
    border.color: hovered ? accent : Qt.alpha(accent, 0.42)
    border.width: 1

    scale: hovered ? 1.025 : 1

    Behavior on scale {
        NumberAnimation {
            duration: 170
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.alpha(root.accent,
                                root.hovered ? 0.28 : 0.15)
            }
            GradientStop {
                position: 1
                color: "#141C30"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 5

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.symbol
                color: root.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 27
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "›"
                color: "#BFCDE8"
                font.pixelSize: 23
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            text: root.title
            color: "#FFFFFF"
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            text: root.subtitle
            color: "#A9B8D5"
            font.pixelSize: 10
            elide: Text.ElideRight
            Layout.fillWidth: true
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
