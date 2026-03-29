#!/bin/zsh
# tmux-claude-status.sh — show count of tmux windows with pending bells.
# Designed for the tmux status bar. Displays a count when any window
# has an unacknowledged bell (i.e. Claude finished and is waiting).
#
# Usage in tmux.conf:
#   set -g status-right '#(~/.local/bin/tmux-claude-status.sh) %H:%M'
#   set -g status-interval 5

bells=$(tmux list-windows -a -F '#{window_bell_flag}' 2>/dev/null | grep -c '^1$')
((bells > 0)) && echo " ${bells}needs-attention"
