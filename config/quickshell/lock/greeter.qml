pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Services.Greetd

ShellRoot {
    id: root
    property string secret: ""
    property bool queuedResponse: false
    property bool waitingResponse: false
    property bool authenticating: false
    property string errorMessage: ""
    property string prompt: "Nhập mật khẩu…"
    readonly property bool preview: Quickshell.env("GREETER_PREVIEW") === "1"
    Component.onCompleted: Quickshell.watchFiles = false

    function submit(password: string): void {
        if (preview || !Greetd.available) {
            errorMessage = "Xem trước màn hình đăng nhập · không xác thực"
            return
        }
        if (authenticating && !waitingResponse) return
        errorMessage = ""
        if (waitingResponse) {
            waitingResponse = false
            Greetd.respond(password)
        } else {
            secret = password
            queuedResponse = true
            authenticating = true
            Greetd.createSession("tam123")
        }
    }
    function clearAuth(message: string): void {
        secret = ""
        queuedResponse = false
        waitingResponse = false
        authenticating = false
        errorMessage = message
        prompt = "Nhập mật khẩu…"
        view.clearPassword()
    }
    Connections {
        target: Greetd
        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (error) root.errorMessage = message
            if (responseRequired) {
                if (root.queuedResponse) {
                    const response = root.secret
                    root.secret = ""
                    root.queuedResponse = false
                    Greetd.respond(response)
                } else {
                    root.prompt = message || "Nhập mật khẩu…"
                    root.waitingResponse = true
                }
            }
        }
        function onAuthFailure(message) { root.clearAuth("Đăng nhập thất bại. Vui lòng kiểm tra mật khẩu.") }
        function onError(error) {
            root.clearAuth("Không thể đăng nhập. Vui lòng thử lại.")
            Greetd.cancelSession()
        }
        function onReadyToLaunch() {
            root.secret = ""
            root.queuedResponse = false
            // Only greetd's authenticated-ready signal may start the user desktop.
            Greetd.launch(["/usr/bin/start-hyprland"], ["XDG_SESSION_TYPE=wayland", "XDG_CURRENT_DESKTOP=Hyprland", "XDG_SESSION_DESKTOP=Hyprland"])
        }
    }
    Window {
        title: "Đăng nhập Arch Linux"
        visible: true
        visibility: root.preview ? Window.Windowed : Window.FullScreen
        flags: Qt.Window | Qt.FramelessWindowHint
        width: 1280
        height: 720
        color: "#101828"
        LockView {
            id: view
            anchors.fill: parent
            loginMode: true
            accountName: "tam123"
            preview: root.preview
            busy: root.authenticating && !root.waitingResponse
            errorMessage: root.errorMessage
            prompt: root.prompt
            onSubmitted: password => root.submit(password)
            onActionRequested: action => {
                if (root.preview || !Greetd.available) {
                    root.errorMessage = "Xem trước · không thực thi nút nguồn"
                    return
                }
                if (action === "shutdown") Quickshell.execDetached(["systemctl", "poweroff"])
                else if (action === "restart") Quickshell.execDetached(["systemctl", "reboot"])
                else if (action === "sleep") Quickshell.execDetached(["systemctl", "suspend"])
            }
            Keys.onEscapePressed: { if (root.preview) Qt.quit() }
        }
    }
}
