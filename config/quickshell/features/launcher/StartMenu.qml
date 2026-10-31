

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Item {
    id: root
    implicitWidth: 32
    implicitHeight: 28

    property bool expanded: false

    function launch(command) {
        Quickshell.execDetached(command)
        expanded = false
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: mouse.containsMouse || root.expanded
               ? "#45475a" : "#313244"

        Text {
            anchors.centerIn: parent
            text: "󰣇"
            color: "#89b4fa"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 19
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    PopupWindow {
        id: popup
        visible: root.expanded
        anchor.item: root

        implicitWidth: 270
        implicitHeight: 310
        color: "#181825"

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: "#181825"
            border.color: "#45475a"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Ứng dụng"
                    color: "#cdd6f4"
                    font.pixelSize: 18
                    font.bold: true
                }

                Repeater {
                    model: [
                        { name: "Google Chrome",
                          icon: "󰊯",
                          cmd: ["google-chrome-stable"] },
                        { name: "Kitty Terminal",
                          icon: "󰆍",
                          cmd: ["kitty"] },
                        { name: "Files",
                          icon: "󰉋",
                          cmd: ["thunar"] },
                        { name: "VS Code",
                          icon: "󰨞",
                          cmd: ["code"] },
                        { name: "Antigravity",
                          icon: "󰚩",
                          cmd: ["antigravity"] }
                    ]

                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 38
                        radius: 8
                        color: appMouse.containsMouse
                               ? "#313244" : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            spacing: 12

                            Text {
                                text: modelData.icon
                                color: "#89b4fa"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 17
                            }

                            Text {
                                text: modelData.name
                                color: "#cdd6f4"
                                font.pixelSize: 13
                            }
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.launch(modelData.cmd)
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
