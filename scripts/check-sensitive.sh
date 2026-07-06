#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

failed=0

echo "Checking for high-confidence secret patterns..."
if rg -n --hidden --glob '!.git/**' \
  'sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{20,}|AKIA[0-9A-Z]{16}' \
  .; then
  failed=1
fi

echo "Checking for uncommented sensitive cmux keys..."
if [ -f config/cmux/cmux.json ]; then
  if awk '
    /^[[:space:]]*\/\// { next }
    /^[[:space:]]*"(.*[Pp]assword.*|.*[Tt]oken.*|.*[Ss]ecret.*|.*[Aa][Pp][Ii].*[Kk]ey.*)"[[:space:]]*:/ { print FILENAME ":" FNR ":" $0; found=1 }
    END { exit found ? 0 : 1 }
  ' config/cmux/cmux.json; then
    failed=1
  fi
fi

if [ "$failed" -ne 0 ]; then
  echo "Potential sensitive data found. Review before committing." >&2
  exit 1
fi

echo "No obvious sensitive data found."

