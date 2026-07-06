#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/bootstrap.sh [--copy]

Install the cmux settings from this repository onto this machine.

Default mode creates symlinks so Git-managed files are used directly.
Use --copy if you prefer one-time copying instead of symlinks.
EOF
}

mode="symlink"
if [ "${1:-}" = "--copy" ]; then
  mode="copy"
elif [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
elif [ "${1:-}" != "" ]; then
  usage >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
timestamp="$(date +%Y%m%d%H%M%S)"

install_file() {
  local source="$1"
  local target="$2"
  local target_dir
  target_dir="$(dirname "$target")"

  if [ ! -f "$source" ]; then
    echo "missing source: $source" >&2
    exit 1
  fi

  mkdir -p "$target_dir"

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$source" -ef "$target" ] 2>/dev/null; then
      echo "already managed: $target"
      return
    fi

    local backup="${target}.backup.${timestamp}"
    mv "$target" "$backup"
    echo "backed up: $target -> $backup"
  fi

  if [ "$mode" = "copy" ]; then
    cp "$source" "$target"
    echo "copied: $source -> $target"
  else
    ln -s "$source" "$target"
    echo "linked: $target -> $source"
  fi
}

install_file "$repo_root/config/cmux/cmux.json" "$HOME/.config/cmux/cmux.json"
install_file "$repo_root/app-support/com.cmuxterm.app/config.ghostty" "$HOME/Library/Application Support/com.cmuxterm.app/config.ghostty"
install_file "$repo_root/app-support/com.cmuxterm.app/config.synced-preview" "$HOME/Library/Application Support/com.cmuxterm.app/config.synced-preview"

echo "cmux settings installed. Restart cmux if it was already running."

