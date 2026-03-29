# --- Claude Code tmux helpers ---
# Source this from your .zshrc, or copy the functions into it.

# Name the current tmux window for a task (e.g. ct SUP-1234/fix-login)
ct() {
  local name="${1:?Usage: ct <task-name>}"
  [ -n "$TMUX" ] && tmux rename-window "$name"
}

# cd into a Claude worktree and auto-name the tmux window from the branch
cw() {
  local dir="${1:?Usage: cw <worktree-path>}"
  cd "$dir" || return 1
  if [ -n "$TMUX" ]; then
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    [ -n "$branch" ] && tmux rename-window "${branch#worktree-}"
  fi
}
