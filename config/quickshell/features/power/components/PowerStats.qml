

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property real cpuUsage: 0
    property real ramUsage: 0
    property real ramUsed: 0
    property real ramTotal: 0
    property real batteryLevel: 0
    property bool hasBattery: false

    property real previousIdle: -1
    property real previousTotal: -1

    implicitWidth: 280
    implicitHeight: 156

    radius: 18
    color: "#DC1A2238"
    border.color: "#52658C"

    function refresh() {
        if (!statsProcess.running)
            statsProcess.running = true
    }

    Process {
        id: statsProcess

        command: [
            "sh", "-c",
            "awk '/^cpu / {idle=$5+$6; total=0; for(i=2;i<=NF;i++) total+=$i; print \"CPU\",idle,total; exit}' /proc/stat; " +
            "awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {printf \"RAM %.0f %.0f\\n\",(t-a)/1024,t/1024}' /proc/meminfo; " +
            "for f in /sys/class/power_supply/BAT*/capacity; do " +
            "if [ -f \"$f\" ]; then printf 'BAT '; cat \"$f\"; break; fi; done"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")

                for (let line of lines) {
                    let p = line.trim().split(/\s+/)

                    if (p[0] === "CPU") {
                        let idle = Number(p[1])
                        let total = Number(p[2])

                        if (root.previousTotal >= 0) {
                            let dt = total - root.previousTotal
                            let di = idle - root.previousIdle
                            if (dt > 0)
                                root.cpuUsage = Math.max(
                                    0, Math.min(100, 100 * (1 - di / dt))
                                )
                        }

                        root.previousIdle = idle
                        root.previousTotal = total
                    }

                    if (p[0] === "RAM") {
                        root.ramUsed = Number(p[1]) / 1024
                        root.ramTotal = Number(p[2]) / 1024
                        root.ramUsage = root.ramTotal > 0
                            ? 100 * root.ramUsed / root.ramTotal : 0
                    }

                    if (p[0] === "BAT") {
                        root.hasBattery = true
                        root.batteryLevel = Number(p[1])
                    }
                }
            }
        }
    }

    Timer {
        interval: 500
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Text {
                text: "󰣇"
                color: "#79B7FF"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 23
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Arch Linux"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                }
                Text {
                    text: "System Monitor"
                    color: "#A9B8D5"
                    font.pixelSize: 10
                }
            }
        }

        Repeater {
            model: [
                { label: "CPU", key: "cpu", color: "#62B6FF" },
                { label: "RAM", key: "ram", color: "#C58AFF" },
                { label: "PIN", key: "battery", color: "#48E6AD" }
            ]

            RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 9

                Text {
                    text: modelData.label
                    color: "#C4D2EB"
                    font.pixelSize: 10
                    Layout.preferredWidth: 32
                }

                Text {
                    text: {
                        if (modelData.key === "cpu")
                            return root.cpuUsage.toFixed(1) + "%"
                        if (modelData.key === "ram")
                            return root.ramUsed.toFixed(1) + " / " +
                                   root.ramTotal.toFixed(1) + " GB"
                        return root.hasBattery
                            ? root.batteryLevel.toFixed(0) + "%" : "N/A"
                    }
                    color: "#FFFFFF"
                    font.pixelSize: 10
                    Layout.preferredWidth: 90
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 7
                    radius: 4
                    color: "#303B56"

                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        color: modelData.color
                        width: parent.width * Math.max(
                            0, Math.min(1,
                                (modelData.key === "cpu"
                                    ? root.cpuUsage
                                    : modelData.key === "ram"
                                      ? root.ramUsage
                                      : root.batteryLevel) / 100))
                        Behavior on width {
                            NumberAnimation { duration: 450 }
                        }
                    }
                }
            }
        }
    }
}
