import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string actionName: ""
    property string symbol: "󰐥"
    property color accent: "#FF789D"

    signal accepted
    signal cancelled

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(420, parent.width - 32)
        spacing: 18

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 76
            Layout.preferredHeight: 76
            radius: 24
            color: Qt.alpha(root.accent, 0.13)
            border.color: Qt.alpha(root.accent, 0.7)

            Text {
                anchors.centerIn: parent
                text: root.symbol
                color: root.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 39
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Xác nhận " + root.actionName + "?"
            color: "#FFFFFF"
            font.pixelSize: 24
            font.bold: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Hãy lưu công việc trước khi tiếp tục."
            color: "#A9B8D5"
            font.pixelSize: 13
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 13
                scale: cancelMouse.pressed ? 0.96 : 1
                Behavior on scale {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 160
                    }
                }
                color: cancelMouse.containsMouse ? "#455371" : "#2C3953"

                Text {
                    anchors.centerIn: parent
                    text: "Hủy"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.cancelled()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 13
                scale: confirmMouse.pressed ? 0.96 : 1
                Behavior on scale {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 160
                    }
                }
                color: confirmMouse.containsMouse ? Qt.lighter(root.accent, 1.15) : root.accent

                Text {
                    anchors.centerIn: parent
                    text: "Xác nhận"
                    color: "#101525"
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    id: confirmMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.accepted()
                }
            }
        }
    }
}
