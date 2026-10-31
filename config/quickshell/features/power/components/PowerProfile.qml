import QtQuick
import "../../../shared/components" as Shared
import QtQuick.Layouts

Item {
    id: root

    property string displayName: "User"
    property string username: "user"
    property string avatarPath: ""
    property string bannerPath: ""

    implicitHeight: 168
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#18233D"
        border.color: "#50688F"
        border.width: 1
        clip: true

        // ẢNH BANNER
        Image {
            anchors.fill: parent
            source: root.bannerPath.length > 0
                    ? "file://" + root.bannerPath
                    : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: 0.85
        }

        // LỚP PHỦ ĐỂ CHỮ DỄ ĐỌC
        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "#E610172A"
                }

                GradientStop {
                    position: 0.50
                    color: "#A010172A"
                }

                GradientStop {
                    position: 1
                    color: "#3010172A"
                }
            }
        }

        Row {
    anchors.left: parent.left
    anchors.leftMargin: 22
    anchors.verticalCenter: parent.verticalCenter

    spacing: 18

    // AVATAR
    Item {
        width: 140
        height: 140

        Rectangle {
            anchors.fill: parent
            radius: 28
            color: "#273C60"
            border.color: "#8FC3FF"
            border.width: 2

            Shared.PowerRoundedImage {
                id: avatarImage
                anchors.fill: parent
                anchors.margins: 4
                cornerRadius: 24

                source: root.avatarPath.length > 0
                        ? "file://" + root.avatarPath
                        : ""
            }

            Text {
                anchors.centerIn: parent
                visible: !avatarImage.imageReady
                text: root.displayName.charAt(0).toUpperCase()
                color: "#E8F2FF"
                font.pixelSize: 42
                font.bold: true
            }
        }

        Rectangle {
            width: 18
            height: 18
            radius: 9
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: "#42F59B"
            border.color: "#18233D"
            border.width: 3
        }
    }

    // THÔNG TIN
    Column {
        width: 340
        anchors.verticalCenter: parent.verticalCenter
        spacing: 9

        Text {
            text: root.displayName
            color: "#FFFFFF"
            font.pixelSize: 27
            font.bold: true
        }

        Text {
            text: "@" + root.username
            color: "#B6C9E8"
            font.pixelSize: 14
        }

        Row {
            spacing: 8

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: "#48F39C"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Online · Hyprland"
                color: "#75F6AC"
                font.pixelSize: 13
            }
        }

        Text {
            text: "Make it simple, but significant."
            color: "#C4CEE5"
            font.pixelSize: 12
            font.italic: true
        }
    }
}
    }
}
