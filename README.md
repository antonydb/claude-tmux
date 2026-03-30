# claude-tmux

Notifications and window management for [Claude Code](https://claude.ai/code) sessions running in tmux.

If you run multiple Claude sessions across tmux windows (e.g. one per feature branch or worktree), this gives you:

- **Bell notifications** when Claude finishes or needs a permission decision — flagged windows show `!` in the tmux status bar
- **macOS notifications** with the window/task name so you know _which_ session needs you
- **Status bar widget** showing a count of windows waiting for attention
- **Auto-named windows** showing `directory:command` (e.g. `my-app:claude`), with manual override via `ct`
- **Shell helpers** for naming tmux windows after tasks (`ct SUP-1234/fix-auth`) or auto-naming from worktree branches (`cw .claude/worktrees/abc`)

## What's included

```
hooks/notify-tmux.sh      # Claude Code hook — bell + macOS notification
bin/tmux-claude-status.sh  # tmux status bar widget
config/tmux.conf           # tmux config snippet
config/claude-hooks.json   # Claude Code hooks config
config/zsh-helpers.zsh     # ct and cw shell functions
install.sh                 # Automated installer
```

## Install

```bash
git clone https://github.com/antonydb/claude-tmux.git
cd claude-tmux
./install.sh
```

The installer is idempotent — safe to re-run. It:

1. Copies `notify-tmux.sh` to `~/.claude/hooks/`
2. Copies `tmux-claude-status.sh` to `~/.local/bin/`
3. Merges hooks into `~/.claude/settings.json` (requires `jq`)
4. Appends the tmux config snippet to `~/.tmux.conf`
5. Appends shell helpers to `~/.zshrc`

After installing, activate in your current session:

```bash
tmux source-file ~/.tmux.conf
source ~/.zshrc
```

Restart any running Claude Code sessions for the hooks to take effect.

## How it works

### Notification flow

```
Claude finishes responding (Stop event)
  └─> notify-tmux.sh
        ├─> printf '\a'          # terminal bell → tmux flags window with "!"
        └─> osascript ...        # macOS notification with window name

Claude needs permission (Notification event)
  └─> notify-tmux.sh
        ├─> printf '\a'
        └─> osascript ...        # "SUP-1234 — needs attention"
```

### tmux status bar

Windows auto-name themselves as `directory:command`. When a window needs attention it's highlighted in yellow with `!`:

```
 0:app:claude !  1:api:nvim  2:app:zsh  3:api:claude !       2needs-attention 14:32
```

Manually renaming a window (with `ct` or `<prefix>,`) sticks — auto-rename is disabled for that window. The status bar widget on the right shows how many windows are waiting.

### Shell helpers

```bash
# Name the current tmux window (use before starting claude)
ct SUP-1234/fix-login

# cd into a worktree and auto-name the window from the branch
cw .claude/worktrees/abc    # window becomes "abc"
```

## Manual setup

If you prefer not to use the install script:

<details>
<summary>Claude Code hooks</summary>

Merge into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notify-tmux.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notify-tmux.sh"
          }
        ]
      }
    ]
  }
}
```

</details>

<details>
<summary>tmux config</summary>

Append to `~/.tmux.conf`:

```tmux
set -g monitor-bell on
set -g bell-action other
set -g visual-bell off
set -g automatic-rename on
set -g automatic-rename-format '#{b:pane_current_path}:#{pane_current_command}'
set -g allow-rename off
set -g window-status-bell-style 'fg=yellow,bold'
set -g window-status-format         '#I:#W#{?window_bell_flag, !,}'
set -g window-status-current-format '#I:#W'
set -g status-right '#(~/.local/bin/tmux-claude-status.sh) %H:%M'
set -g status-interval 5
```

</details>

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- tmux
- macOS (for `osascript` notifications — bell works on any platform)
- `jq` (for install script's settings merge)

## License

MIT
