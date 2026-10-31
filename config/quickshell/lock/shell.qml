pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

ShellRoot {
    id: root
    property string pendingPassword: ""
    property bool hasResponse: false
    property string errorMessage: ""
    property bool suspendAfterLock: false
    signal clearPasswords

    function requestLock(suspend: bool): void {
        errorMessage = "";
        suspendAfterLock = suspend;
        sessionLock.locked = true;
        if (sessionLock.secure && suspendAfterLock) {
            suspendAfterLock = false;
            Quickshell.execDetached(["systemctl", "suspend"]);
        }
    }
    function submit(password: string): void {
        if (!sessionLock.secure || (pam.active && !pam.responseRequired))
            return;
        errorMessage = "";
        if (pam.active && pam.responseRequired) {
            pam.respond(password);
        } else {
            pendingPassword = password;
            hasResponse = true;
            if (!pam.start()) {
                pendingPassword = "";
                hasResponse = false;
                errorMessage = "Không thể bắt đầu xác thực. Vui lòng thử lại.";
            }
        }
        clearPasswords();
    }
    IpcHandler {
        target: "lock"
        function lock(): void {
            root.requestLock(false);
        }
        function sleep(): void {
            root.requestLock(true);
        }
    }
    // Listen to loginctl lock-session (e.g. from a session manager).
    Process {
        command: ["sh", Quickshell.shellDir + "/scripts/watch-lock.sh"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.indexOf("member=Lock") !== -1)
                    root.requestLock(false);
            }
        }
    }
    PamContext {
        id: pam
        configDirectory: Quickshell.shellDir + "/pam"
        config: "lock"
        onPamMessage: {
            if (responseRequired && root.hasResponse) {
                const response = root.pendingPassword;
                root.pendingPassword = "";
                root.hasResponse = false;
                respond(response);
            }
        }
        onCompleted: result => {
            root.pendingPassword = "";
            root.hasResponse = false;
            root.clearPasswords();
            if (result === PamResult.Success) {
                sessionLock.locked = false;
                root.errorMessage = "";
            } else {
                root.errorMessage = result === PamResult.Error ? "Lỗi xác thực PAM. Vui lòng thử lại." : "Mật khẩu chưa đúng hoặc tài khoản tạm khóa. Thử lại sau.";
            }
        }
    }
    WlSessionLock {
        id: sessionLock
        // Never replace a live lock surface while editing configuration.
        onLockedChanged: Quickshell.watchFiles = !locked
        onSecureChanged: {
            if (secure && root.suspendAfterLock) {
                root.suspendAfterLock = false;
                Quickshell.execDetached(["systemctl", "suspend"]);
            }
        }
        WlSessionLockSurface {
            LockView {
                id: view
                anchors.fill: parent
                busy: pam.active && !pam.responseRequired
                errorMessage: root.errorMessage
                prompt: pam.responseRequired && pam.responseVisible ? pam.message : "Nhập mật khẩu…"
                onSubmitted: password => root.submit(password)
                onActionRequested: action => {
                    if (action === "sleep")
                        Quickshell.execDetached(["systemctl", "suspend"]);
                    else if (action === "shutdown")
                        Quickshell.execDetached(["systemctl", "poweroff"]);
                    else if (action === "restart")
                        Quickshell.execDetached(["systemctl", "reboot"]);
                    else if (action === "logout")
                        Quickshell.execDetached(["loginctl", "terminate-user", Quickshell.env("USER")]);
                }
                Connections {
                    target: root
                    function onClearPasswords() {
                        view.clearPassword();
                    }
                }
            }
        }
    }
}
