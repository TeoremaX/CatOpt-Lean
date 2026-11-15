#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/check_no_sorry.py
python3 -m unittest discover -s experiments -p 'test_*.py' -v
if command -v lake >/dev/null 2>&1; then
  lake build
  lake exe catopt-demo
else
  echo 'Lean/Lake not installed; skipped formal compilation (this is NOT a passing proof check).' >&2
  exit 2
fi
