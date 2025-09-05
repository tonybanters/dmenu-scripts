#!/bin/sh
set -eu

# Grab only directories inside ~/debian-dotfiles
configs="$(ls -1d ~/tonybtw/repos/*/ 2>/dev/null | xargs -n1 basename)"
[ -n "$configs" ] || exit 0

chosen="$(printf '%s\n' $configs | dmenu -i -c -vi -bw 3 -W 600 -l 30 -h 40 -F -fn "JetBrainsMono Nerd Font:size=16" -p 'repos:')"
[ -n "$chosen" ] || exit 0

dir="$HOME/tonybtw/repos/$chosen"

# If inside tmux: switch or create
if [ "${TMUX-}" ]; then
  if tmux has-session -t "$chosen" 2>/dev/null; then
    exec tmux switch-client -t "$chosen"
  else
    exec tmux new-session -s "$chosen" -c "$dir" "nvim ."
  fi
fi

# If there's an st client running tmux, switch that instead of opening a new one
client_tty="$(
  tmux list-clients -F '#{client_tty} #{client_termname}' 2>/dev/null \
  | awk '$2 ~ /^st/ { print $1; exit }' || true
)"

if [ -n "${client_tty}" ]; then
  if tmux has-session -t "$chosen" 2>/dev/null; then
    tmux switch-client -c "${client_tty}" -t "$chosen"
  else
    tmux new-session -s "$chosen" -c "$dir" "nvim ."
  fi
  exit 0
fi

# Otherwise, spawn a new st terminal
if tmux has-session -t "$chosen" 2>/dev/null; then
  exec st -e tmux attach -t "$chosen"
else
  exec st -e tmux new-session -s "$chosen" -c "$dir" "nvim ."
fi


