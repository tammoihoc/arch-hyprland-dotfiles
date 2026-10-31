import QtQuick

Rectangle {
    id: root
    property string symbol: ""
    property string label: ""
    property color accent: "#80B7FF"
    signal activated
    width: 124
    height: 120
    radius: 24
    color: mouse.containsMouse ? "#DA23314C" : "#B312192A"
    border.color: mouse.containsMouse ? Qt.alpha(accent, 0.65) : "#203F5279"
    scale: mouse.pressed ? 0.94 : 1
    transform: Translate {
        y: mouse.containsMouse ? -4 : 0
        Behavior on y {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 140
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: 180
        }
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 12
        width: 66
        height: 66
        radius: 33
        color: "#40111B2D"
        border.width: 2
        border.color: Qt.alpha(root.accent, 0.3)
        Text {
            anchors.centerIn: parent
            text: root.symbol
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 34
            color: root.accent
        }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 88
        text: root.label
        color: "#E8EDFF"
        font.pixelSize: 13
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
