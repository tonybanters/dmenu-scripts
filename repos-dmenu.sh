#!/bin/sh
set -eu

# Pick repo
configs="$(ls -1d "$HOME"/repos/*/ 2>/dev/null | xargs -n1 basename)"
[ -n "$configs" ] || exit 0
chosen="$(printf '%s\n' $configs | dmenu -i -c -bw 3 -W 600 -l 30 -h 40 -F -fn 'JetBrainsMono Nerd Font:size=16' -p 'Projects:')"
[ -n "$chosen" ] || exit 0
dir="$HOME/repos/$chosen"

# Nuke any existing st (since you only use one terminal)
pkill -x st 2>/dev/null || true
sleep 0.1

# Launch a clean terminal: attach if exists, else create
# exec st -e tmux new-session -As "$chosen" -c "$dir" "nvim ."
exec st -e tmux new-session -As "$chosen" -c "$dir"

