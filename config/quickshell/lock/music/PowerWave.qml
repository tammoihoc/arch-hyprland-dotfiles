
pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property bool playing: false
    property real phase: 0

    implicitWidth: 220
    implicitHeight: 76

    // Cập nhật sóng khoảng 30 FPS
    Timer {
        interval: 33
        repeat: true
        running: root.playing

        onTriggered: {
            root.phase += 0.12

            if (root.phase > Math.PI * 200)
                root.phase = 0
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: 28

            Item {
                id: waveItem

                required property int index

                width: 5
                height: root.height

                readonly property real amplitude: {
                    if (!root.playing)
                        return 0

                    const a = Math.abs(
                        Math.sin(root.phase * 1.5 + index * 0.53)
                    )

                    const b = Math.abs(
                        Math.cos(root.phase * 0.8 - index * 0.37)
                    )

                    return 0.2 + 0.8 * a * b
                }

                Rectangle {
                    id: bar

                    anchors.centerIn: parent

                    width: 4

                    height: root.playing
                        ? 12 + waveItem.amplitude * 54
                        : 5

                    radius: 2

                    color: {
                        if (waveItem.index < 9)
                            return "#5ACBFF"

                        if (waveItem.index < 19)
                            return "#BB8CFF"

                        return "#FF78B9"
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 3
                        height: parent.height + 4
                        radius: width / 2
                        color: parent.color
                        opacity: 0.18
                        z: -1
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log(
            "[PowerWave] loaded",
            "playing:", playing,
            "size:", width, height
        )
    }

    onPlayingChanged: {
        console.log("[PowerWave] playing:", playing)
    }
}
