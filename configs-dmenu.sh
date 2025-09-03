#!/bin/sh
set -eu

# Grab only directories inside ~/debian-dotfiles
configs="$(ls -1d ~/debian-dotfiles/*/ 2>/dev/null | xargs -n1 basename)"
[ -n "$configs" ] || exit 0

chosen="$(printf '%s\n' $configs | dmenu -i -vi -c -bw 3 -l 10 -h 30 -F -p 'configs:')"
[ -n "$chosen" ] || exit 0

dir="$HOME/debian-dotfiles/$chosen"

# If inside tmux, just switch session (create it if missing)
if [ "${TMUX-}" ]; then
  if tmux has-session -t "$chosen" 2>/dev/null; then
    exec tmux switch-client -t "$chosen"
  else
    exec tmux new-session -s "$chosen" -c "$dir" "nvim ."
  fi
fi

# Outside tmux: open st, create or attach session running nvim
if tmux has-session -t "$chosen" 2>/dev/null; then
  exec st -e tmux attach -t "$chosen"
else
  exec st -e tmux new-session -s "$chosen" -c "$dir" "nvim ."
fi
