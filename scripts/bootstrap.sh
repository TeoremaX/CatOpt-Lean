#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v lake >/dev/null 2>&1; then
  echo 'Install elan/Lean: https://lean-lang.org/install/' >&2
  exit 1
fi
lake update
lake exe cache get
lake build
lake exe catopt-demo
