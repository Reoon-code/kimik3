#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM="$ROOT/upstream"
PIN="117e9d29bde14db9742f54fb66a191fd0bf03903"

[[ -d "$UPSTREAM/.git" ]] || { echo "error: run ./scripts/bootstrap.sh first" >&2; exit 2; }
actual="$(git -C "$UPSTREAM" rev-parse HEAD)"
[[ "$actual" == "$PIN" ]] || { echo "error: upstream is $actual; expected $PIN" >&2; exit 1; }

make -C "$UPSTREAM" test -j"${KIMIK3_JOBS:-2}"
"$UPSTREAM/bin/k3" --list-presets | grep -Eq '^  ultra[[:space:]]+2\.50 / 0\.31'
"$UPSTREAM/bin/k3" --help | grep -q -- '--ultra-low-memory'

echo "PASS: pinned source, tests, ultra preset and ultra-low-memory CLI contract verified."
