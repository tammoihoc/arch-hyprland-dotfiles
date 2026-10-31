
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Rectangle {
    id: root

    property var player: null

    readonly property bool playing:
        player !== null &&
        player.playbackState === MprisPlaybackState.Playing

    readonly property real duration:
        player && player.lengthSupported ? player.length : 0

    readonly property real position:
        player && player.positionSupported ? player.position : 0

    implicitHeight: 208
    radius: 20
    clip: true
    color: "#141C30"
    border.color: "#536A9B"
    border.width: 1

    function selectPlayer() {
        const players = Mpris.players.values

        if (!players || players.length === 0) {
            root.player = null
            return
        }

        // Giữ player hiện tại nếu vẫn đang phát
        if (root.player &&
            players.indexOf(root.player) !== -1 &&
            root.player.playbackState === MprisPlaybackState.Playing)
            return

        // Ưu tiên player đang phát
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) {
                root.player = players[i]
                return
            }
        }

        // Nếu không ai phát, giữ player đang tạm dừng
        if (root.player && players.indexOf(root.player) !== -1)
            return

        root.player = players[0]
    }

    function formatTime(value) {
        if (!isFinite(value) || value < 0)
            return "0:00"

        const seconds = Math.floor(value)
        return Math.floor(seconds / 60) + ":" +
               String(seconds % 60).padStart(2, "0")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            root.selectPlayer()

            if (root.player && root.playing &&
                root.player.positionSupported)
                root.player.positionChanged()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0
                color: "#30305B"
            }

            GradientStop {
                position: 0.55
                color: "#1A2542"
            }

            GradientStop {
                position: 1
                color: "#122C38"
            }
        }
    }

    // Ánh sáng trang trí
    Rectangle {
        width: 180
        height: 180
        radius: 90
        x: -70
        y: 15
        color: "#554A9DFF"
        opacity: root.playing ? 0.28 : 0.10

        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 20

        // ĐĨA NHẠC
        PowerMusicDisc {
            Layout.preferredWidth: 144
            Layout.preferredHeight: 144
            Layout.alignment: Qt.AlignVCenter

            coverUrl: root.player
                ? root.player.trackArtUrl : ""

            playing: root.playing
        }

        // NỘI DUNG
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    width: 7
                    height: 7
                    radius: 4
                    color: root.playing ? "#4DF5A2" : "#7C8BAA"
                }

                Text {
                    text: root.playing
                        ? "NOW PLAYING"
                        : root.player ? "PAUSED" : "NO MEDIA"

                    color: "#8CB6FF"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.player
                        ? (root.player.identity || "Media Player")
                        : "MPRIS"

                    color: "#93A8CD"
                    font.pixelSize: 10
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: root.player
                            ? (root.player.trackTitle || "Không có tiêu đề")
                            : "Chưa phát nhạc hoặc video"

                        color: "#FFFFFF"
                        font.pixelSize: 19
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.player
                            ? (root.player.trackArtist ||
                               root.player.identity || "Unknown Artist")
                            : "Mở Chrome, Spotify hoặc VLC"

                        color: "#AFC3E6"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                }

PowerWave {
    Layout.preferredWidth: 220
    Layout.preferredHeight: 70
    Layout.alignment: Qt.AlignVCenter
    playing: root.playing
}
            }

            Item { Layout.fillHeight: true }

            // THANH THỜI LƯỢNG
            Rectangle {
                id: progressTrack

                Layout.fillWidth: true
                height: 6
                radius: 3
                color: "#3A4968"

                Rectangle {
                    height: parent.height
                    radius: 3
                    color: "#85AFFF"

                    width: parent.width * (
                        root.duration > 0
                        ? Math.max(0, Math.min(1,
                            root.position / root.duration))
                        : 0
                    )

                    Behavior on width {
                        NumberAnimation { duration: 250 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.player !== null &&
                             root.player.canSeek &&
                             root.player.positionSupported &&
                             root.duration > 0

                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        const fraction = Math.max(0, Math.min(1,
                            mouse.x / width))

                        root.player.position =
                            fraction * root.duration
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: root.formatTime(root.position)
                    color: "#9DAFD0"
                    font.pixelSize: 10
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.formatTime(root.duration)
                    color: "#9DAFD0"
                    font.pixelSize: 10
                }
            }

            // BA NÚT NẰM NGANG DƯỚI THỜI LƯỢNG
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 22

                Repeater {
                    model: [
                        {
                            icon: "󰒮",
                            action: "previous"
                        },
                        {
                            icon: root.playing ? "󰏤" : "󰐊",
                            action: "toggle"
                        },
                        {
                            icon: "󰒭",
                            action: "next"
                        }
                    ]

                    Rectangle {
                        id: control

                        required property var modelData

                        readonly property bool mainButton:
                            modelData.action === "toggle"

                        readonly property bool available: {
                            if (!root.player) return false
                            if (modelData.action === "previous")
                                return root.player.canGoPrevious
                            if (modelData.action === "next")
                                return root.player.canGoNext
                            return root.player.canTogglePlaying
                        }

                        width: mainButton ? 46 : 36
                        height: mainButton ? 46 : 36
                        radius: width / 2

                        opacity: available ? 1 : 0.4

                        color: mainButton
                            ? (controlMouse.containsMouse
                                ? "#A2C0FF" : "#78A5FF")
                            : (controlMouse.containsMouse
                                ? "#43577C" : "#2A3A58")

                        scale: controlMouse.pressed ? 0.92 : 1

                        Behavior on scale {
                            NumberAnimation { duration: 120 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: control.modelData.icon

                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: control.mainButton ? 23 : 21

                            color: control.mainButton
                                ? "#10182B" : "#E4ECFF"
                        }

                        MouseArea {
                            id: controlMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: control.available
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (!root.player) return

                                switch (control.modelData.action) {
                                case "previous":
                                    root.player.previous()
                                    break

                                case "toggle":
                                    root.player.togglePlaying()
                                    break

                                case "next":
                                    root.player.next()
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
