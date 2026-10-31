import QtQuick
import Quickshell.Io

Row {
    id: root
    spacing: 16
    property real cpuUsage: 0
    property real ramUsage: 0
    property real ramUsed: 0
    property real ramTotal: 0
    property real batteryLevel: 0
    property bool hasBattery: false

    property real previousIdle: -1
    property real previousTotal: -1

    function refresh() {
        if (!statsProcess.running)
            statsProcess.running = true;
    }

    Process {
        id: statsProcess

        command: ["sh", "-c", "awk '/^cpu / {idle=$5+$6; total=0; for(i=2;i<=NF;i++) total+=$i; print \"CPU\",idle,total; exit}' /proc/stat; " + "awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {printf \"RAM %.0f %.0f\\n\",(t-a)/1024,t/1024}' /proc/meminfo; " + "for f in /sys/class/power_supply/BAT*/capacity; do " + "if [ -f \"$f\" ]; then printf 'BAT '; cat \"$f\"; break; fi; done"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");

                for (let line of lines) {
                    let p = line.trim().split(/\s+/);

                    if (p[0] === "CPU") {
                        let idle = Number(p[1]);
                        let total = Number(p[2]);

                        if (root.previousTotal >= 0) {
                            let dt = total - root.previousTotal;
                            let di = idle - root.previousIdle;
                            if (dt > 0)
                                root.cpuUsage = Math.max(0, Math.min(100, 100 * (1 - di / dt)));
                        }

                        root.previousIdle = idle;
                        root.previousTotal = total;
                    }

                    if (p[0] === "RAM") {
                        root.ramUsed = Number(p[1]) / 1024;
                        root.ramTotal = Number(p[2]) / 1024;
                        root.ramUsage = root.ramTotal > 0 ? 100 * root.ramUsed / root.ramTotal : 0;
                    }

                    if (p[0] === "BAT") {
                        root.hasBattery = true;
                        root.batteryLevel = Number(p[1]);
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Repeater {
        model: [
            {
                icon: "󰻠",
                label: "CPU",
                value: root.cpuUsage.toFixed(0) + "%"
            },
            {
                icon: "󰍛",
                label: "RAM",
                value: root.ramUsed.toFixed(1) + " / " + root.ramTotal.toFixed(1) + " GB"
            },
            {
                icon: "󰁹",
                label: "PIN",
                value: root.hasBattery ? root.batteryLevel.toFixed(0) + "%" : "AC"
            }
        ]
        Rectangle {
            id: statChip
            required property var modelData
            width: chip.implicitWidth + 30
            height: 44
            radius: 22
            color: "#A00C1321"
            border.color: "#627FAF"
            Row {
                id: chip
                anchors.centerIn: parent
                spacing: 10
                Text {
                    text: statChip.modelData.icon
                    color: "#8FC8FF"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                }
                Text {
                    text: statChip.modelData.label + "   " + statChip.modelData.value
                    color: "#E7EDFF"
                    font.pixelSize: 14
                }
            }
        }
    }
}
