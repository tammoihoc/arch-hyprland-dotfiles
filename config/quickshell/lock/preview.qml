import QtQuick
import Quickshell

ShellRoot {
    FloatingWindow {
        id: window
        title: "Xem trước màn hình khóa"
        implicitWidth: 1280
        implicitHeight: 720
        color: "#101828"
        LockView {
            id: view
            anchors.fill: parent
            preview: true
            onSubmitted: password => {
                errorMessage = "Chế độ xem trước · không xác thực mật khẩu";
            }
            onActionRequested: action => {
                errorMessage = "Xem trước: " + action + " (không thực thi)";
            }
            Keys.onEscapePressed: Qt.quit()
        }
        // Optional headless screenshot for layout verification.
        Timer {
            interval: 2000
            running: Quickshell.env("LOCK_PREVIEW_CAPTURE") !== ""
            onTriggered: view.grabToImage(result => {
                result.saveToFile(Quickshell.env("LOCK_PREVIEW_CAPTURE"));
                Qt.quit();
            })
        }
    }
}
