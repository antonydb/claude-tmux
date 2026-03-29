#!/bin/bash
# Claude Code hook: ring terminal bell and send macOS notification.
# Shared by Stop and Notification hooks in ~/.claude/settings.json.
#
# When Claude finishes responding or needs permission, this script:
#   1. Rings the terminal bell (tmux picks this up as a window bell flag)
#   2. Sends a macOS notification with the tmux window name for context

# Read hook input (required by hook contract)
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name' 2>/dev/null)

# Ring terminal bell (write to tty so it works regardless of stdout redirection)
printf '\a' >/dev/tty 2>/dev/null || true

# macOS notification with tmux window context
if command -v osascript &>/dev/null; then
  WIN=""
  [ -n "$TMUX" ] && WIN=$(tmux display-message -p '#W' 2>/dev/null)
  LABEL="${WIN:-Claude}"

  case "$EVENT" in
    Stop) MSG="$LABEL — ready for review" ;;
    *)    MSG="$LABEL — needs attention" ;;
  esac

  # Background so we don't block Claude
  osascript -e "display notification \"$MSG\" with title \"Claude Code\" sound name \"Glass\"" &>/dev/null &
fi
