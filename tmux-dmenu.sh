#!/bin/sh
set -eu

TMUX_BIN="$(command -v tmux || { echo 'tmux not found'; exit 1; })"
DMENU_BIN="$(command -v dmenu || { echo 'dmenu not found'; exit 1; })"

DMENU_OPTS='-i -vi -c -bw 3 -W 600 -l 30 -h 40 -F -fn JetBrainsMono\ Nerd\ Font:size=16 -p Sessions:'

# List existing sessions (just names)
sessions="$("$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null || true)"

# Add a "create new" entry at the top
menu="Create new session…\n$sessions"

choice="$(printf '%b' "$menu" | eval "$DMENU_BIN $DMENU_OPTS" || true)"
[ -n "$choice" ] || exit 0

if [ "$choice" = "Create new session…" ]; then
    new_name="$(printf '' | eval "$DMENU_BIN -c -bw 3 -W 600 -F -fn JetBrainsMono\\ Nerd\\ Font:size=16 -p 'New session name:'" || true)"
    [ -n "$new_name" ] || exit 0
    session="$new_name"
    create=1
else
    session="$choice"
    create=0
fi

# Inside tmux: create (detached) if needed, then switch (NO exec on create)
if [ -n "${TMUX-}" ]; then
    if [ "$create" -eq 1 ] && ! "$TMUX_BIN" has-session -t "$session" 2>/dev/null; then
        "$TMUX_BIN" new-session -ds "$session"
    fi
    exec "$TMUX_BIN" switch-client -t "$session"
fi

# Outside tmux: one-terminal behavior
pkill -x st 2>/dev/null || true
sleep 0.1

if [ "$create" -eq 1 ]; then
    # create and attach
    exec st -e "$TMUX_BIN" new-session -s "$session"
else
    # attach existing
    exec st -e "$TMUX_BIN" attach -t "$session"
fi
