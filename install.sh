#!/bin/bash
# install.sh — set up Claude Code + tmux integration
#
# What it does:
#   1. Copies the notification hook to ~/.claude/hooks/
#   2. Copies the status bar script to ~/.local/bin/
#   3. Merges hook config into ~/.claude/settings.json (requires jq)
#   4. Appends tmux config snippet to ~/.tmux.conf
#   5. Appends shell helpers to ~/.zshrc
#
# Safe to re-run — skips steps that are already done.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

info()  { printf '\033[1;34m=>\033[0m %s\n' "$@"; }
ok()    { printf '\033[1;32m=>\033[0m %s\n' "$@"; }
warn()  { printf '\033[1;33m=>\033[0m %s\n' "$@"; }

# --- 1. Hook script ---
info "Installing notification hook..."
mkdir -p ~/.claude/hooks
cp "$SCRIPT_DIR/hooks/notify-tmux.sh" ~/.claude/hooks/notify-tmux.sh
chmod +x ~/.claude/hooks/notify-tmux.sh
ok "Installed ~/.claude/hooks/notify-tmux.sh"

# --- 2. Status bar script ---
info "Installing status bar script..."
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/bin/tmux-claude-status.sh" ~/.local/bin/tmux-claude-status.sh
chmod +x ~/.local/bin/tmux-claude-status.sh
ok "Installed ~/.local/bin/tmux-claude-status.sh"

# --- 3. Claude Code hooks config ---
SETTINGS="$HOME/.claude/settings.json"
if [ -f "$SETTINGS" ] && grep -q '"Stop"' "$SETTINGS" 2>/dev/null; then
  ok "Claude hooks already configured in $SETTINGS — skipping"
else
  info "Adding hooks to $SETTINGS..."
  if ! command -v jq &>/dev/null; then
    warn "jq not found — cannot auto-merge hooks. Merge config/claude-hooks.json into $SETTINGS manually."
  else
    if [ -f "$SETTINGS" ]; then
      # Merge hooks into existing settings
      HOOKS=$(cat "$SCRIPT_DIR/config/claude-hooks.json")
      jq --argjson hooks "$(echo "$HOOKS" | jq '.hooks')" '. + {hooks: $hooks}' "$SETTINGS" > "${SETTINGS}.tmp"
      mv "${SETTINGS}.tmp" "$SETTINGS"
    else
      # No existing settings — create from hook config
      mkdir -p ~/.claude
      cp "$SCRIPT_DIR/config/claude-hooks.json" "$SETTINGS"
    fi
    ok "Added hooks to $SETTINGS"
  fi
fi

# --- 4. tmux config ---
TMUX_CONF="$HOME/.tmux.conf"
if [ -f "$TMUX_CONF" ] && grep -q 'Claude Code integration' "$TMUX_CONF" 2>/dev/null; then
  ok "tmux config already present in $TMUX_CONF — skipping"
else
  info "Appending tmux config..."
  echo "" >> "$TMUX_CONF"
  cat "$SCRIPT_DIR/config/tmux.conf" >> "$TMUX_CONF"
  ok "Appended Claude config to $TMUX_CONF"
fi

# --- 5. Shell helpers ---
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ] && grep -q 'Claude Code tmux helpers' "$ZSHRC" 2>/dev/null; then
  ok "Shell helpers already present in $ZSHRC — skipping"
else
  info "Appending shell helpers to $ZSHRC..."
  echo "" >> "$ZSHRC"
  cat "$SCRIPT_DIR/config/zsh-helpers.zsh" >> "$ZSHRC"
  ok "Appended helpers to $ZSHRC"
fi

echo ""
ok "Done! To activate:"
echo "   tmux source-file ~/.tmux.conf"
echo "   source ~/.zshrc"
echo ""
echo "   Restart any running Claude Code sessions for hooks to take effect."
