#!/bin/sh
set -eu
config_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
case "${1:-lock}" in
    preview) exec quickshell -n -p "$config_dir/preview.qml" ;;
    daemon) exec quickshell -n -d -p "$config_dir/shell.qml" ;;
    lock|sleep) action=${1:-lock} ;;
    *) printf 'Usage: %s [lock|sleep|preview|daemon]\n' "$0" >&2; exit 2 ;;
esac
quickshell -n -d -p "$config_dir/shell.qml"
# The IPC endpoint can appear shortly after the daemon starts.
attempt=0
until quickshell ipc -p "$config_dir/shell.qml" call lock "$action"; do
    attempt=$((attempt + 1))
    [ "$attempt" -lt 25 ] || exit 1
    sleep 0.1
done
