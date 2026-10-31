import QtQuick
import QtQuick.Layouts

Rectangle {
    color: "#1e1e2e"
    radius: 8
    border.color: "#45475a"
    border.width: 1
    implicitWidth: clockRow.implicitWidth + 20
    implicitHeight: 28

    RowLayout {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: "󰃰"
            color: "#cba6f7"
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            id: clockText
            color: "#cdd6f4"
            font.pixelSize: 12
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var date = new Date()
                    clockText.text = date.toLocaleDateString(Qt.locale("vi_VN"), "ddd, dd/MM/yyyy") + "  |  " + date.toLocaleTimeString(Qt.locale("vi_VN"), "hh:mm:ss")
                }
            }
        }
    }
}
