# Managed files

This repository tracks portable cmux settings only.

## Included

- `config/cmux/cmux.json`
  - Source: `~/.config/cmux/cmux.json`
  - cmux JSONC settings file.
- `app-support/com.cmuxterm.app/config.ghostty`
  - Source: `~/Library/Application Support/com.cmuxterm.app/config.ghostty`
  - cmux terminal theme settings.
- `app-support/com.cmuxterm.app/config.synced-preview`
  - Source: `~/Library/Application Support/com.cmuxterm.app/config.synced-preview`
  - Currently empty on this machine, but tracked so future synced preview settings have a stable place.

## Excluded

These files are intentionally not tracked:

- `~/.cmuxterm/*.jsonl`
- `~/.cmuxterm/claude-hook-sessions.json`
- `~/Library/Application Support/cmux/search.db*`
- `~/Library/Application Support/cmux/session-*.json`
- `~/Library/Application Support/cmux/cmux.sock`
- `~/Library/Application Support/com.cmuxterm.app/browser_history.json`
- `~/Library/Application Support/com.cmuxterm.app/phc_*/`
- `~/Library/Preferences/com.cmuxterm.app.plist`

They contain local sessions, logs, browser history, sockets, telemetry/cache data, window geometry, machine-specific identifiers, or values that are safer to leave per-device.

