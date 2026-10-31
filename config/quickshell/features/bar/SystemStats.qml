import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Quickshell.Io

RowLayout {
    id: statsRoot
    spacing: 8

    property string ramUsage: "-- / 16 GB"
    property string cpuUsage: "--%"
    property real _cpuPrevIdle: -1
    property real _cpuPrevTotal: -1
    property string wifiSsid: "Disconnected"
    property string wifiIcon: "󰤮"
    property string volumeText: "--%"
    property string volumeIcon: "󰕾"

    // Process RAM
    Process {
        id: ramProcess
        command: ["sh", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%.2f / %.1f GB\", (t-a)/1048576, t/1048576}' /proc/meminfo"]
        stdout: SplitParser { onRead: data => statsRoot.ramUsage = data.trim() }
    }

    // Process Volume
    Process {
        id: audioProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                let str = data.trim()
                if (str.includes("[MUTED]")) {
                    statsRoot.volumeIcon = "󰝟"
                    statsRoot.volumeText = "Mute"
                } else {
                    let parts = str.split(" ")
                    if (parts.length >= 2) {
                        let val = Math.round(parseFloat(parts[1]) * 100)
                        statsRoot.volumeText = val + "%"
                        if (val > 60) statsRoot.volumeIcon = "󰕾"
                        else if (val > 20) statsRoot.volumeIcon = "󰖀"
                        else statsRoot.volumeIcon = "󰕿"
                    }
                }
            }
        }
    }

    // Process CPU %
    Process {
        id: cpuProcess
        command: ["sh", "-c", "awk '/^cpu /{idle=$5+$6; total=0; for(i=2;i<=NF;i++) total+=$i; print idle, total}' /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(/\s+/)
                if (parts.length < 2) return
                let idle = parseFloat(parts[0])
                let total = parseFloat(parts[1])

                if (statsRoot._cpuPrevTotal >= 0) {
                    let dTotal = total - statsRoot._cpuPrevTotal
                    let dIdle = idle - statsRoot._cpuPrevIdle
                    if (dTotal > 0) {
                        let usage = (1.0 - dIdle / dTotal) * 100.0
                        statsRoot.cpuUsage = Math.max(0, Math.min(100, usage)).toFixed(1) + "%"
                    }
                }
                statsRoot._cpuPrevIdle = idle
                statsRoot._cpuPrevTotal = total
            }
        }
    }

    // Process Wi-Fi
    Process {
        id: wifiProcess
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes'"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":")
                if (parts.length >= 3) {
                    statsRoot.wifiSsid = parts[1]
                    let signal = parseInt(parts[2])
                    if (signal > 75) statsRoot.wifiIcon = "󰤨"
                    else if (signal > 50) statsRoot.wifiIcon = "󰤥"
                    else if (signal > 25) statsRoot.wifiIcon = "󰤢"
                    else statsRoot.wifiIcon = "󰤟"
                } else {
                    statsRoot.wifiSsid = "Ngắt kết nối"
                    statsRoot.wifiIcon = "󰤮"
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ramProcess.running = true
            cpuProcess.running = true
            wifiProcess.running = true
            audioProcess.running = true
        }
    }

    // UI Blocks
    // Block CPU
    Rectangle {
        color: "#1e1e2e"; radius: 8
        implicitWidth: cpuRow.implicitWidth + 14; implicitHeight: 28
        RowLayout {
            id: cpuRow; anchors.centerIn: parent; spacing: 6
            Text { text: ""; color: "#89b4fa"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
            Text { text: statsRoot.cpuUsage; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
        }
    }

    // Block RAM
    Rectangle {
        color: "#1e1e2e"; radius: 8
        implicitWidth: ramRow.implicitWidth + 14; implicitHeight: 28
        RowLayout {
            id: ramRow; anchors.centerIn: parent; spacing: 6
            Text { text: "󰍛"; color: "#a6e3a1"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
            Text { text: statsRoot.ramUsage; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
        }
    }

    // Block Wi-Fi
    Rectangle {
        color: "#1e1e2e"; radius: 8
        implicitWidth: wifiRow.implicitWidth + 14; implicitHeight: 28
        RowLayout {
            id: wifiRow; anchors.centerIn: parent; spacing: 6
            Text { text: statsRoot.wifiIcon; color: "#89dceb"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
            Text { text: statsRoot.wifiSsid; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
        }
    }

    // Block Audio
    Rectangle {
        color: "#1e1e2e"; radius: 8
        implicitWidth: audioRow.implicitWidth + 14; implicitHeight: 28
        RowLayout {
            id: audioRow; anchors.centerIn: parent; spacing: 6
            Text {
                text: statsRoot.volumeIcon
                color: statsRoot.volumeText === "Mute" ? "#f38ba8" : "#f5c2e7"
                font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"
            }
            Text { text: statsRoot.volumeText; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
        }
    }

    // Block Pin
    Rectangle {
        color: "#1e1e2e"; radius: 8
        implicitWidth: batRow.implicitWidth + 14; implicitHeight: 28
        RowLayout {
            id: batRow; anchors.centerIn: parent; spacing: 6
            property var bat: UPower.displayDevice

            Text {
                text: {
                    if (!parent.bat) return "󰂎"
                    if (parent.bat.charging) return "󰂄"
                    let perc = parent.bat.percentage
                    if (perc > 0.9) return "󰁹"
                    if (perc > 0.6) return "󰁿"
                    if (perc > 0.3) return "󰁽"
                    return "󰁺"
                }
                color: parent.bat && parent.bat.percentage < 0.2 ? "#f38ba8" : "#f9e2af"
                font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                text: parent.bat ? Math.round(parent.bat.percentage * 100) + "%" : "100%"
                color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
}
