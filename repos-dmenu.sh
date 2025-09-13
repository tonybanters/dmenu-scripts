#!/bin/sh
set -eu

# Set your terminal:
terminal="st"

# Set your dmenu flags
dmenu_flags="-i -vi -c -bw 3 -W 600 -l 30 -h 40 -F -fn 'JetBrainsMono Nerd Font:size=16' -p 'Projects:'"

# Pick repo
configs="$(ls -1d "$HOME"/repos/*/ 2>/dev/null | xargs -n1 basename)"
[ -n "$configs" ] || exit 0
chosen="$(printf '%s\n' $configs | dmenu $dmenu_flags)"
[ -n "$chosen" ] || exit 0
dir="$HOME/repos/$chosen"

# Nuke any existing st (since you only use one terminal)
pkill -x $terminal 2>/dev/null || true
sleep 0.1

# Launch a clean terminal: attach if exists, else create
exec $terminal -e tmux new-session -As "$chosen" -c "$dir"

