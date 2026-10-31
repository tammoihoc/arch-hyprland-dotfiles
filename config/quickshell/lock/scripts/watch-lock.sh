#!/bin/sh
# Resolve this session's exact D-Bus object path so other sessions do not affect it.
session_id=${XDG_SESSION_ID:-$(loginctl show-session self -p Id --value)}
session_path=$(busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager GetSession s "$session_id" | cut -d '"' -f 2)
case "$session_path" in /org/freedesktop/login1/session/*) ;; *) exit 1 ;; esac
# Exec keeps the monitor owned by Quickshell; no orphan pipeline on reload.
exec dbus-monitor --system "type='signal',path='$session_path',interface='org.freedesktop.login1.Session',member='Lock'"
