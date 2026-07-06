#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

python3 scripts/build-config.py --check
python3 -m json.tool cmux.json >/dev/null
cmux config check
scripts/check-sensitive.sh
