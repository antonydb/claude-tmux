#!/bin/zsh
# tmux-claude-status.sh — show count of windows with pending bells in the status bar.
# Add to tmux.conf:  set -g status-right '#(~/.local/bin/tmux-claude-status.sh) %H:%M'

bells=$(tmux list-windows -a -F '#{window_bell_flag}' 2>/dev/null | grep -c '^1$')
((bells > 0)) && echo " ${bells}needs-attention"
