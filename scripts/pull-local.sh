#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

copy_from_local() {
  local local_path="$1"
  local repo_path="$2"
  local repo_dir
  repo_dir="$(dirname "$repo_path")"

  if [ ! -e "$local_path" ]; then
    echo "missing local file, skipped: $local_path"
    return
  fi

  mkdir -p "$repo_dir"

  if [ "$local_path" -ef "$repo_path" ] 2>/dev/null; then
    echo "already same file: $local_path"
    return
  fi

  cp "$local_path" "$repo_path"
  echo "updated: $repo_path"
}

copy_from_local "$HOME/.config/cmux/cmux.json" "$repo_root/cmux.json"
copy_from_local "$HOME/Library/Application Support/com.cmuxterm.app/config.ghostty" "$repo_root/app-support/com.cmuxterm.app/config.ghostty"
copy_from_local "$HOME/Library/Application Support/com.cmuxterm.app/config.synced-preview" "$repo_root/app-support/com.cmuxterm.app/config.synced-preview"

"$repo_root/scripts/check-sensitive.sh"
