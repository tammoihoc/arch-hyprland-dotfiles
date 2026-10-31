import "../../../shared/components" as Shared

import QtQuick

Item {
    id: root

    property string coverUrl: ""
    property bool playing: false

    implicitWidth: 150
    implicitHeight: 150

    // Vòng sáng ngoài
    Rectangle {
        anchors.centerIn: parent
        width: 148
        height: 148
        radius: 74

        color: "#172846"
        border.color: "#70A9FF"
        border.width: 2
    }

    Rectangle {
        anchors.centerIn: parent
        width: 139
        height: 139
        radius: 70
        color: "#12182A"
        border.color: "#4269A8"
        border.width: 1
    }

    Item {
        id: rotatingDisc

        anchors.centerIn: parent
        width: 132
        height: 132

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "#080C18"
            border.color: "#52698F"
            border.width: 2
        }

        Shared.PowerRoundedImage {
            anchors.centerIn: parent

            width: 120
            height: 120

            cornerRadius: 60
            source: root.coverUrl
        }

        // Vòng tròn trang trí
        Rectangle {
            anchors.centerIn: parent
            width: 38
            height: 38
            radius: 19

            color: "#440C1222"
            border.color: "#88A8D8"
            border.width: 1
        }

        // Trục đĩa
        Rectangle {
            anchors.centerIn: parent
            width: 11
            height: 11
            radius: 6
            color: "#E7F1FF"
            border.color: "#51698D"
            border.width: 3
        }

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 9000
            loops: Animation.Infinite
            running: root.playing
        }
    }
}
